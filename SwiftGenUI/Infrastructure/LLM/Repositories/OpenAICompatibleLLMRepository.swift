//
//  OpenAICompatibleLLMRepository.swift
//  SwiftGenUI
//
//  OpenAI-compatible implementation used by providers like OpenRouter.
//

import Foundation

struct OpenAICompatibleLLMRepository: LLMRepository {
    private let endpoint: URL
    private let modelName: String
    private let apiKey: String
    private let providerName: String
    private let promptBuilder: PromptBuilder
    private let screenPlanPromptBuilder: ScreenPlanPromptBuilder
    private let screenSectionPromptBuilder: ScreenSectionPromptBuilder
    private let urlSession: URLSession
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    init(
        configuration: CustomEndpointConfiguration,
        providerName: String,
        promptBuilder: PromptBuilder = PromptBuilder(),
        screenPlanPromptBuilder: ScreenPlanPromptBuilder = ScreenPlanPromptBuilder(),
        screenSectionPromptBuilder: ScreenSectionPromptBuilder = ScreenSectionPromptBuilder(),
        urlSession: URLSession = .shared,
        jsonEncoder: JSONEncoder = JSONEncoder(),
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) throws {
        guard let endpoint = Self.chatCompletionsEndpoint(from: configuration.baseURL) else {
            throw LLMError.invalidConfiguration("Invalid \(providerName) base URL")
        }

        let apiKey = configuration.apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !apiKey.isEmpty, apiKey != "YOUR_KEY_HERE" else {
            throw LLMError.missingAPIKey("\(providerName) API key")
        }

        let modelName = configuration.modelID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !modelName.isEmpty, modelName != "YOUR_MODEL_ID_HERE" else {
            throw LLMError.invalidConfiguration("Missing \(providerName) model ID")
        }

        self.endpoint = endpoint
        self.modelName = modelName
        self.apiKey = apiKey
        self.providerName = providerName
        self.promptBuilder = promptBuilder
        self.screenPlanPromptBuilder = screenPlanPromptBuilder
        self.screenSectionPromptBuilder = screenSectionPromptBuilder
        self.urlSession = urlSession
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    func generateSchema(from prompt: String) async throws -> UIComponent {
        let response = try await generateResponse(
            prompt: promptBuilder.buildPrompt(userPrompt: prompt),
            maxTokens: 1800,
            operation: "single_schema"
        )
        debugLog("\(providerName) raw schema response:\n\(response)")
        return try decodeComponent(from: response)
    }

    func generateScreenPlan(from prompt: String) async throws -> ScreenPlan {
        let response = try await generateResponse(
            prompt: screenPlanPromptBuilder.buildPrompt(userPrompt: prompt),
            maxTokens: 520,
            operation: "screen_plan"
        )
        debugLog("\(providerName) raw screen plan response:\n\(response)")

        let cleanedJSON = cleanJSONString(response)
        guard let data = cleanedJSON.data(using: .utf8) else {
            throw LLMError.invalidJSON
        }

        return try jsonDecoder.decode(ScreenPlanDTO.self, from: data).toScreenPlan()
    }

    func generateScreenSection(from input: ScreenSectionGenerationInput) async throws -> UIComponent {
        let response = try await generateResponse(
            prompt: screenSectionPromptBuilder.buildPrompt(input: input),
            maxTokens: 900,
            operation: "section_\(input.section.id)"
        )
        debugLog("\(providerName) raw \(input.section.title) section response:\n\(response)")
        return try decodeComponent(from: response)
    }

    func retryScreenSection(from input: ScreenSectionGenerationInput) async throws -> UIComponent {
        let response = try await generateResponse(
            prompt: screenSectionPromptBuilder.buildRetryPrompt(input: input),
            maxTokens: 600,
            operation: "section_retry_\(input.section.id)"
        )
        debugLog("\(providerName) retry \(input.section.title) section response:\n\(response)")
        return try decodeComponent(from: response)
    }

    private func generateResponse(
        prompt: String,
        maxTokens: Int,
        operation: String
    ) async throws -> String {
        let requestDTO = OpenAICompatibleChatRequestDTO(
            model: modelName,
            messages: [
                .init(role: "user", content: prompt)
            ],
            temperature: 0.2,
            maxTokens: maxTokens,
            responseFormat: .init(type: "json_object")
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 300
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("SwiftGenUI", forHTTPHeaderField: "X-Title")
        request.httpBody = try jsonEncoder.encode(requestDTO)

        let startedAt = Date()
        debugLog("SwiftGenUI LLM request started. provider=\(providerName) operation=\(operation) model=\(modelName) endpoint=\(endpoint.absoluteString) maxTokens=\(maxTokens)")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            debugLog("SwiftGenUI LLM request failed. provider=\(providerName) operation=\(operation) phase=transport duration=\(formattedDuration(since: startedAt)) error=\(error.localizedDescription)")
            throw error
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            debugLog("SwiftGenUI LLM request failed. provider=\(providerName) operation=\(operation) phase=response duration=\(formattedDuration(since: startedAt)) error=invalid_http_response")
            throw LLMError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            debugLog("SwiftGenUI LLM request failed. provider=\(providerName) operation=\(operation) phase=http status=\(httpResponse.statusCode) duration=\(formattedDuration(since: startedAt))")
            if let body = String(data: data, encoding: .utf8), !body.isEmpty {
                debugLog("SwiftGenUI LLM failure body. provider=\(providerName) operation=\(operation)\n\(body)")
            }
            throw LLMError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decodedResponse = try jsonDecoder.decode(OpenAICompatibleChatResponseDTO.self, from: data)
            guard let content = decodedResponse.choices.first?.message.content, !content.isEmpty else {
                throw LLMError.emptyResponse
            }

            debugLog("SwiftGenUI LLM request succeeded. provider=\(providerName) operation=\(operation) status=\(httpResponse.statusCode) duration=\(formattedDuration(since: startedAt)) responseCharacters=\(content.count)")
            return content
        } catch {
            debugLog("SwiftGenUI LLM request failed. provider=\(providerName) operation=\(operation) phase=decode status=\(httpResponse.statusCode) duration=\(formattedDuration(since: startedAt)) error=\(error.localizedDescription)")
            if let body = String(data: data, encoding: .utf8), !body.isEmpty {
                debugLog("SwiftGenUI LLM decode body. provider=\(providerName) operation=\(operation)\n\(body)")
            }
            throw error
        }
    }

    private static func chatCompletionsEndpoint(from baseURLString: String) -> URL? {
        let trimmedBaseURL = baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedBaseURL.isEmpty else {
            return nil
        }

        if trimmedBaseURL.hasSuffix("/chat/completions") {
            return URL(string: trimmedBaseURL)
        }

        return URL(string: trimmedBaseURL)?
            .appendingPathComponent("chat")
            .appendingPathComponent("completions")
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

        guard let data = cleanedJSON.data(using: .utf8) else {
            throw LLMError.invalidJSON
        }

        if let compactDTO = try? jsonDecoder.decode(CompactComponentDTO.self, from: data) {
            return try compactDTO.toUIComponent()
        }

        return try jsonDecoder.decode(UIComponent.self, from: data)
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
