
import Foundation

struct OllamaLLMRepository: LLMRepository {
    private let endpoint: URL
    private let modelName: String
    private let promptBuilder: PromptBuilder
    private let screenPlanPromptBuilder: ScreenPlanPromptBuilder
    private let screenSectionPromptBuilder: ScreenSectionPromptBuilder
    private let urlSession: URLSession
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    init(
        endpoint: URL = URL(string: "http://localhost:11434/api/generate")!,
        modelName: String = "qwen2.5-coder:14b",
        promptBuilder: PromptBuilder = PromptBuilder(),
        screenPlanPromptBuilder: ScreenPlanPromptBuilder = ScreenPlanPromptBuilder(),
        screenSectionPromptBuilder: ScreenSectionPromptBuilder = ScreenSectionPromptBuilder(),
        urlSession: URLSession = .shared,
        jsonEncoder: JSONEncoder = JSONEncoder(),
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.endpoint = endpoint
        self.modelName = modelName
        self.promptBuilder = promptBuilder
        self.screenPlanPromptBuilder = screenPlanPromptBuilder
        self.screenSectionPromptBuilder = screenSectionPromptBuilder
        self.urlSession = urlSession
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    func generateSchema(from prompt: String) async throws -> UIComponent {
        let ollamaResponse = try await generateResponse(
            prompt: promptBuilder.buildPrompt(userPrompt: prompt),
            numPredict: 1800,
            operation: "single_schema"
        )
        #if DEBUG
        print("Ollama raw schema response:\n\(ollamaResponse.response)")
        #endif

        return try decodeComponent(from: ollamaResponse.response)
    }

    func generateScreenPlan(from prompt: String) async throws -> ScreenPlan {
        let ollamaResponse = try await generateResponse(
            prompt: screenPlanPromptBuilder.buildPrompt(userPrompt: prompt),
            numPredict: 420,
            operation: "screen_plan"
        )
        #if DEBUG
        print("Ollama raw screen plan response:\n\(ollamaResponse.response)")
        #endif

        let cleanedJSON = cleanJSONString(ollamaResponse.response)

        guard let planData = cleanedJSON.data(using: .utf8) else {
            throw LLMError.invalidJSON
        }

        return try jsonDecoder.decode(ScreenPlanDTO.self, from: planData).toScreenPlan()
    }

    func generateScreenSection(from input: ScreenSectionGenerationInput) async throws -> UIComponent {
        let ollamaResponse = try await generateResponse(
            prompt: screenSectionPromptBuilder.buildPrompt(input: input),
            numPredict: 900,
            operation: "section_\(input.section.id)"
        )
        #if DEBUG
        print("Ollama raw \(input.section.title) section response:\n\(ollamaResponse.response)")
        #endif

        return try decodeComponent(from: ollamaResponse.response)
    }

    func retryScreenSection(from input: ScreenSectionGenerationInput) async throws -> UIComponent {
        let ollamaResponse = try await generateResponse(
            prompt: screenSectionPromptBuilder.buildRetryPrompt(input: input),
            numPredict: 520,
            operation: "section_retry_\(input.section.id)"
        )
        #if DEBUG
        print("Ollama retry \(input.section.title) section response:\n\(ollamaResponse.response)")
        #endif

        return try decodeComponent(from: ollamaResponse.response)
    }

    private func generateResponse(
        prompt: String,
        numPredict: Int,
        operation: String
    ) async throws -> OllamaGenerateResponseDTO {
        let requestDTO = OllamaGenerateRequestDTO(
            model: modelName,
            prompt: prompt,
            stream: false,
            format: "json",
            keepAlive: "30s",
            options: .init(
                temperature: 0.2,
                numPredict: numPredict,
                numContext: 4096,
                numThread: 4
            )
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 300
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try jsonEncoder.encode(requestDTO)

        let startedAt = Date()
        debugLog("SwiftGenUI LLM request started. provider=Ollama operation=\(operation) model=\(modelName) endpoint=\(endpoint.absoluteString) numPredict=\(numPredict)")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            debugLog("SwiftGenUI LLM request failed. provider=Ollama operation=\(operation) phase=transport duration=\(formattedDuration(since: startedAt)) error=\(error.localizedDescription)")
            throw error
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            debugLog("SwiftGenUI LLM request failed. provider=Ollama operation=\(operation) phase=response duration=\(formattedDuration(since: startedAt)) error=invalid_http_response")
            throw LLMError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            debugLog("SwiftGenUI LLM request failed. provider=Ollama operation=\(operation) phase=http status=\(httpResponse.statusCode) duration=\(formattedDuration(since: startedAt))")
            if let body = String(data: data, encoding: .utf8), !body.isEmpty {
                debugLog("SwiftGenUI LLM failure body. provider=Ollama operation=\(operation)\n\(body)")
            }
            throw LLMError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decodedResponse = try jsonDecoder.decode(OllamaGenerateResponseDTO.self, from: data)
            debugLog("SwiftGenUI LLM request succeeded. provider=Ollama operation=\(operation) status=\(httpResponse.statusCode) duration=\(formattedDuration(since: startedAt)) responseCharacters=\(decodedResponse.response.count)")
            return decodedResponse
        } catch {
            debugLog("SwiftGenUI LLM request failed. provider=Ollama operation=\(operation) phase=decode status=\(httpResponse.statusCode) duration=\(formattedDuration(since: startedAt)) error=\(error.localizedDescription)")
            if let body = String(data: data, encoding: .utf8), !body.isEmpty {
                debugLog("SwiftGenUI LLM decode body. provider=Ollama operation=\(operation)\n\(body)")
            }
            throw error
        }
    }

    private func cleanJSONString(_ string: String) -> String {
        var cleaned = string
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let startIndex = cleaned.firstIndex(of: "{"),
           let endIndex = cleaned.lastIndex(of: "}") {
            cleaned = String(cleaned[startIndex...endIndex])
        }

        return cleaned
    }

    private func decodeComponent(from response: String) throws -> UIComponent {
        let cleanedJSON = cleanJSONString(response)

        guard let componentData = cleanedJSON.data(using: .utf8) else {
            throw LLMError.invalidJSON
        }

        if let compactDTO = try? jsonDecoder.decode(CompactComponentDTO.self, from: componentData) {
            return try compactDTO.toUIComponent()
        }

        return try jsonDecoder.decode(UIComponent.self, from: componentData)
    }

    private func debugLog(_ message: String) {
        #if DEBUG
        print(message)
        #endif
    }

    private func formattedDuration(since startDate: Date) -> String {
        String(format: "%.2fs", Date().timeIntervalSince(startDate))
    }
}

enum LLMError: LocalizedError, Equatable {
    case invalidResponse
    case invalidJSON
    case emptyResponse
    case missingAPIKey(String)
    case invalidConfiguration(String)
    case serverError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from LLM provider"
        case .invalidJSON:
            return "LLM provider returned invalid UI schema JSON"
        case .emptyResponse:
            return "LLM returned an empty response"
        case let .missingAPIKey(name):
            return "Missing \(name)"
        case let .invalidConfiguration(message):
            return message
        case let .serverError(statusCode):
            return "LLM provider returned HTTP \(statusCode)"
        }
    }
}
