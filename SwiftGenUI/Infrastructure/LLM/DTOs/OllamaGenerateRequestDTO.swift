//
//  OllamaGenerateRequestDTO.swift
//  SwiftGenUI
//
//  Request payload for Ollama's generate endpoint.
//

import Foundation

struct OllamaGenerateRequestDTO: Encodable {
    let model: String
    let prompt: String
    let stream: Bool
    let format: String
    let keepAlive: String
    let options: Options

    enum CodingKeys: String, CodingKey {
        case model
        case prompt
        case stream
        case format
        case keepAlive = "keep_alive"
        case options
    }

    struct Options: Encodable {
        let temperature: Double
        let numPredict: Int
        let numContext: Int
        let numThread: Int

        enum CodingKeys: String, CodingKey {
            case temperature
            case numPredict = "num_predict"
            case numContext = "num_ctx"
            case numThread = "num_thread"
        }
    }
}
