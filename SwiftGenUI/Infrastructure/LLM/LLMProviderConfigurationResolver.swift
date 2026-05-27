//
//  LLMProviderConfigurationResolver.swift
//  SwiftGenUI
//
//  Resolves provider defaults and xcconfig-backed values outside feature state.
//

import Foundation

nonisolated enum LLMProviderConfigurationResolver {
    static func configuration(
        for provider: LLMProvider,
        currentConfiguration: CustomEndpointConfiguration
    ) -> CustomEndpointConfiguration {
        var configuration = currentConfiguration

        if provider != .customEndpoint {
            let defaults = provider.defaultConfiguration
            configuration.baseURL = configuration.baseURL.nonEmptyValue ?? defaults.baseURL
            configuration.modelID = configuration.modelID.nonEmptyValue ?? defaults.modelID
            configuration.providerFormat = defaults.providerFormat
        }

        switch provider {
        case .openRouter:
            configuration.apiKey = configuration.apiKey.nonEmptyValue ?? AppEnvironment.openRouterAPIKey
            configuration.baseURL = AppEnvironment.customLLMBaseURL.nonEmptyValue ?? configuration.baseURL
            configuration.modelID = AppEnvironment.customLLMModelID.nonEmptyValue ?? configuration.modelID

        case .openAI:
            configuration.apiKey = configuration.apiKey.nonEmptyValue ?? AppEnvironment.openAIAPIKey

        case .gemini:
            configuration.apiKey = configuration.apiKey.nonEmptyValue ?? AppEnvironment.geminiAPIKey

        case .localOllama, .customEndpoint:
            break
        }

        return configuration
    }
}

nonisolated private enum AppEnvironment {
    enum Keys {
        static let openRouterAPIKey = "OPENROUTER_API_KEY"
        static let openAIAPIKey = "OPENAI_API_KEY"
        static let geminiAPIKey = "GEMINI_API_KEY"
        static let customLLMBaseURL = "CUSTOM_LLM_BASE_URL"
        static let customLLMModelID = "CUSTOM_LLM_MODEL_ID"
    }

    static var openRouterAPIKey: String {
        value(for: Keys.openRouterAPIKey)
    }

    static var openAIAPIKey: String {
        value(for: Keys.openAIAPIKey)
    }

    static var geminiAPIKey: String {
        value(for: Keys.geminiAPIKey)
    }

    static var customLLMBaseURL: String {
        value(for: Keys.customLLMBaseURL)
    }

    static var customLLMModelID: String {
        value(for: Keys.customLLMModelID)
    }

    private static func value(for key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            return ""
        }

        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.hasPrefix("$(") ? "" : trimmedValue
    }
}

private extension String {
    nonisolated var nonEmptyValue: String? {
        let trimmedValue = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty || trimmedValue == "YOUR_KEY_HERE" ? nil : trimmedValue
    }
}
