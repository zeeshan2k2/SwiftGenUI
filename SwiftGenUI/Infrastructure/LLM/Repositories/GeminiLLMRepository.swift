//
//  GeminiLLMRepository.swift
//  SwiftGenUI
//
//  Gemini generateContent implementation for prompt-to-schema generation.
//

import Foundation

struct GeminiLLMRepository: LLMRepository {
    private let endpoint: URL
    private let modelName: String
    private let apiKey: String
    private let promptBuilder: PromptBuilder
    private let screenPlanPromptBuilder: ScreenPlanPromptBuilder
    private let screenSectionPromptBuilder: ScreenSectionPromptBuilder
    private let urlSession: URLSession
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    init(
        configuration: CustomEndpointConfiguration,
        promptBuilder: PromptBuilder = PromptBuilder(),
        screenPlanPromptBuilder: ScreenPlanPromptBuilder = ScreenPlanPromptBuilder(),
        screenSectionPromptBuilder: ScreenSectionPromptBuilder = ScreenSectionPromptBuilder(),
        urlSession: URLSession = .shared,
        jsonEncoder: JSONEncoder = JSONEncoder(),
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) throws {
        let apiKey = configuration.apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !apiKey.isEmpty, apiKey != "YOUR_KEY_HERE" else {
            throw LLMError.missingAPIKey("Gemini API key")
        }

        let modelName = configuration.modelID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !modelName.isEmpty, modelName != "YOUR_MODEL_ID_HERE" else {
            throw LLMError.invalidConfiguration("Missing Gemini model ID")
        }

        guard let endpoint = Self.generateContentEndpoint(
            from: configuration.baseURL,
            modelName: modelName
        ) else {
            throw LLMError.invalidConfiguration("Invalid Gemini base URL")
        }

        self.endpoint = endpoint
        self.modelName = modelName
        self.apiKey = apiKey
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
        debugLog("Gemini raw schema response:\n\(response)")
        return try decodeComponent(from: response)
    }

    func generateScreenPlan(from prompt: String) async throws -> ScreenPlan {
        let response = try await generateResponse(
            prompt: screenPlanPromptBuilder.buildPrompt(userPrompt: prompt),
            maxTokens: 520,
            operation: "screen_plan"
        )
        debugLog("Gemini raw screen plan response:\n\(response)")

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
        debugLog("Gemini raw \(input.section.title) section response:\n\(response)")
        return try decodeComponent(from: response)
    }

    func retryScreenSection(from input: ScreenSectionGenerationInput) async throws -> UIComponent {
        let response = try await generateResponse(
            prompt: screenSectionPromptBuilder.buildRetryPrompt(input: input),
            maxTokens: 600,
            operation: "section_retry_\(input.section.id)"
        )
        debugLog("Gemini retry \(input.section.title) section response:\n\(response)")
        return try decodeComponent(from: response)
    }

    private func generateResponse(
        prompt: String,
        maxTokens: Int,
        operation: String
    ) async throws -> String {
        let requestDTO = GeminiGenerateContentRequestDTO(
            contents: [
                .init(
                    role: "user",
                    parts: [.init(text: prompt)]
                )
            ],
            generationConfig: .init(
                temperature: 0.2,
                maxOutputTokens: maxTokens,
                responseMimeType: "application/json"
            )
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 300
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        request.httpBody = try jsonEncoder.encode(requestDTO)

        let startedAt = Date()
        debugLog("SwiftGenUI LLM request started. provider=Gemini operation=\(operation) model=\(modelName) endpoint=\(endpoint.absoluteString) maxTokens=\(maxTokens)")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            debugLog("SwiftGenUI LLM request failed. provider=Gemini operation=\(operation) phase=transport duration=\(formattedDuration(since: startedAt)) error=\(error.localizedDescription)")
            throw error
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            debugLog("SwiftGenUI LLM request failed. provider=Gemini operation=\(operation) phase=response duration=\(formattedDuration(since: startedAt)) error=invalid_http_response")
            throw LLMError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            debugLog("SwiftGenUI LLM request failed. provider=Gemini operation=\(operation) phase=http status=\(httpResponse.statusCode) duration=\(formattedDuration(since: startedAt))")
            if let body = String(data: data, encoding: .utf8), !body.isEmpty {
                debugLog("SwiftGenUI LLM failure body. provider=Gemini operation=\(operation)\n\(body)")
            }
            throw LLMError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decodedResponse = try jsonDecoder.decode(GeminiGenerateContentResponseDTO.self, from: data)
            let content = decodedResponse.candidates?
                .first?
                .content?
                .parts?
                .compactMap(\.text)
                .joined()

            guard let content, !content.isEmpty else {
                throw LLMError.emptyResponse
            }

            debugLog("SwiftGenUI LLM request succeeded. provider=Gemini operation=\(operation) status=\(httpResponse.statusCode) duration=\(formattedDuration(since: startedAt)) responseCharacters=\(content.count)")
            return content
        } catch {
            debugLog("SwiftGenUI LLM request failed. provider=Gemini operation=\(operation) phase=decode status=\(httpResponse.statusCode) duration=\(formattedDuration(since: startedAt)) error=\(error.localizedDescription)")
            if let body = String(data: data, encoding: .utf8), !body.isEmpty {
                debugLog("SwiftGenUI LLM decode body. provider=Gemini operation=\(operation)\n\(body)")
            }
            throw error
        }
    }

    private static func generateContentEndpoint(
        from baseURLString: String,
        modelName: String
    ) -> URL? {
        let trimmedBaseURL = baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedBaseURL.isEmpty else {
            return nil
        }

        if trimmedBaseURL.hasSuffix(":generateContent") {
            return URL(string: trimmedBaseURL)
        }

        return URL(string: trimmedBaseURL)?
            .appendingPathComponent("models")
            .appendingPathComponent("\(modelName):generateContent")
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
