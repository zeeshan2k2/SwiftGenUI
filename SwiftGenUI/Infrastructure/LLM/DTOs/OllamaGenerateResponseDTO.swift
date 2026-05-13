//
//  OllamaGenerateResponseDTO.swift
//  SwiftGenUI
//
//  Response payload from Ollama's generate endpoint.
//

import Foundation

struct OllamaGenerateResponseDTO: Decodable {
    let response: String
}
