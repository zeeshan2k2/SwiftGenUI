//
//  LLMRepository.swift
//  SwiftGenUI
//
//  Data boundary for prompt-to-schema generation.
//

import Foundation

protocol LLMRepository {
    func generateSchema(from prompt: String) async throws -> UIComponent
}
