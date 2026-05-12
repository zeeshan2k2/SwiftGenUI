//
//  LLMClient.swift
//  SwiftGenUI
//
//  Abstraction for prompt-to-schema generation.
//

import Foundation

protocol LLMClient {
    func generateSchema(from prompt: String) async throws -> UIComponent
}
