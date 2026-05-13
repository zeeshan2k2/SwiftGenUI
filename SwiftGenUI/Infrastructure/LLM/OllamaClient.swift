//
//  OllamaClient.swift
//  SwiftGenUI
//
//  Local Ollama-backed LLM client adapter.
//

import Foundation

struct OllamaClient {
    private let repository: LLMRepository

    init(repository: LLMRepository = OllamaLLMRepository()) {
        self.repository = repository
    }

    func generateSchema(from prompt: String) async throws -> UIComponent {
        try await repository.generateSchema(from: prompt)
    }
}
