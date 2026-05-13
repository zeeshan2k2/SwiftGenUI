//
//  OllamaLLMRepository.swift
//  SwiftGenUI
//
//  Ollama implementation of the LLM data boundary.
//

import Foundation

struct OllamaLLMRepository: LLMRepository {
    private let endpoint: URL
    private let modelName: String
    private let promptBuilder: PromptBuilder
    private let urlSession: URLSession
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    init(
        endpoint: URL = URL(string: "http://localhost:11434/api/generate")!,
        modelName: String = "qwen2.5-coder:14b",
        promptBuilder: PromptBuilder = PromptBuilder(),
        urlSession: URLSession = .shared,
        jsonEncoder: JSONEncoder = JSONEncoder(),
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.endpoint = endpoint
        self.modelName = modelName
        self.promptBuilder = promptBuilder
        self.urlSession = urlSession
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    func generateSchema(from prompt: String) async throws -> UIComponent {
        let requestDTO = OllamaGenerateRequestDTO(
            model: modelName,
            prompt: promptBuilder.buildPrompt(userPrompt: prompt),
            stream: false,
            format: "json",
            keepAlive: "30s",
            options: .init(
                temperature: 0.2,
                numPredict: 700,
                numContext: 4096,
                numThread: 4
            )
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 120
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try jsonEncoder.encode(requestDTO)

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LLMError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw LLMError.serverError(statusCode: httpResponse.statusCode)
        }

        let ollamaResponse = try jsonDecoder.decode(OllamaGenerateResponseDTO.self, from: data)
        let cleanedJSON = cleanJSONString(ollamaResponse.response)

        guard let componentData = cleanedJSON.data(using: .utf8) else {
            throw LLMError.invalidJSON
        }

        return try jsonDecoder.decode(UIComponent.self, from: componentData)
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
}

enum LLMError: LocalizedError, Equatable {
    case invalidResponse
    case invalidJSON
    case serverError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from Ollama"
        case .invalidJSON:
            return "Ollama returned invalid UI schema JSON"
        case let .serverError(statusCode):
            return "Ollama returned HTTP \(statusCode)"
        }
    }
}
