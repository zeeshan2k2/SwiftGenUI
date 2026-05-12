//
//  OllamaClient.swift
//  SwiftGenUI
//
//  Local Ollama-backed LLM client placeholder.
//

import Foundation

struct OllamaClient: LLMClient {
    func generateSchema(from prompt: String) async throws -> UIComponent {
        _ = prompt

        return UIComponent(
            id: UUID().uuidString,
            type: .text,
            props: ComponentProps(text: "Generated UI placeholder"),
            children: nil,
            capability: nil
        )
    }
}
