//
//  LLMProviderConfiguration.swift
//  SwiftGenUI
//
//  Runtime configuration for selectable LLM providers.
//

import Foundation

nonisolated enum LLMProvider: String, Equatable, CaseIterable, Sendable {
    case localOllama
    case openRouter
    case openAI
    case gemini
    case customEndpoint

    var title: String {
        switch self {
        case .localOllama:
            return "Local Qwen"
        case .openRouter:
            return "OpenRouter"
        case .openAI:
            return "OpenAI"
        case .gemini:
            return "Gemini"
        case .customEndpoint:
            return "Custom API"
        }
    }

    var sheetTitle: String {
        switch self {
        case .localOllama:
            return "Local Ollama"
        case .openRouter:
            return "OpenRouter"
        case .openAI:
            return "OpenAI"
        case .gemini:
            return "Gemini"
        case .customEndpoint:
            return "Custom Endpoint"
        }
    }

    var subtitle: String {
        switch self {
        case .localOllama:
            return "Qwen 2.5 Coder 14B via localhost"
        case .openRouter:
            return "OpenAI-compatible gateway with free model options"
        case .openAI:
            return "OpenAI API using chat completions"
        case .gemini:
            return "Google Gemini API configuration"
        case .customEndpoint:
            return "Manual provider URL, model, key, and format"
        }
    }

    var systemImage: String {
        switch self {
        case .localOllama:
            return "desktopcomputer"
        case .openRouter:
            return "point.3.connected.trianglepath.dotted"
        case .openAI:
            return "sparkles"
        case .gemini:
            return "diamond"
        case .customEndpoint:
            return "link.badge.plus"
        }
    }

    var defaultConfiguration: CustomEndpointConfiguration {
        switch self {
        case .localOllama:
            return CustomEndpointConfiguration(
                baseURL: "http://localhost:11434/api/generate",
                modelID: "qwen2.5-coder:14b",
                apiKey: "",
                providerFormat: .ollamaCompatible
            )
        case .openRouter:
            return CustomEndpointConfiguration(
                baseURL: "https://openrouter.ai/api/v1",
                modelID: "qwen/qwen3-coder:free",
                apiKey: "",
                providerFormat: .openAICompatible
            )
        case .openAI:
            return CustomEndpointConfiguration(
                baseURL: "https://api.openai.com/v1",
                modelID: "gpt-4.1-mini",
                apiKey: "",
                providerFormat: .openAICompatible
            )
        case .gemini:
            return CustomEndpointConfiguration(
                baseURL: "https://generativelanguage.googleapis.com/v1beta",
                modelID: "gemini-2.5-flash",
                apiKey: "",
                providerFormat: .gemini
            )
        case .customEndpoint:
            return CustomEndpointConfiguration()
        }
    }
}

nonisolated enum ProviderFormat: String, Equatable, CaseIterable, Sendable {
    case openAICompatible
    case gemini
    case ollamaCompatible

    var title: String {
        switch self {
        case .openAICompatible:
            return "OpenAI-compatible"
        case .gemini:
            return "Gemini"
        case .ollamaCompatible:
            return "Ollama-compatible"
        }
    }
}

nonisolated struct CustomEndpointConfiguration: Equatable, Sendable {
    var baseURL = ""
    var modelID = ""
    var apiKey = ""
    var providerFormat: ProviderFormat = .openAICompatible
}
