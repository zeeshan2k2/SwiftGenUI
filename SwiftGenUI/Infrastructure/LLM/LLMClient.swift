//
//  LLMClient.swift
//  SwiftGenUI
//
//  TCA dependency for prompt-to-schema generation.
//

import ComposableArchitecture
import Foundation

struct LLMClient {
    var generateSchema: (String, LLMProvider, CustomEndpointConfiguration) async throws -> UIComponent
    var generateScreenPlan: (String, LLMProvider, CustomEndpointConfiguration) async throws -> ScreenPlan
    var generateScreenSection: (ScreenSectionGenerationInput, LLMProvider, CustomEndpointConfiguration) async throws -> UIComponent
    var retryScreenSection: (ScreenSectionGenerationInput, LLMProvider, CustomEndpointConfiguration) async throws -> UIComponent
}

extension LLMClient: DependencyKey {
    static let liveValue = LLMClient(
        generateSchema: { prompt, provider, configuration in
            try await repository(for: provider, configuration: configuration).generateSchema(from: prompt)
        },
        generateScreenPlan: { prompt, provider, configuration in
            try await repository(for: provider, configuration: configuration).generateScreenPlan(from: prompt)
        },
        generateScreenSection: { input, provider, configuration in
            try await repository(for: provider, configuration: configuration).generateScreenSection(from: input)
        },
        retryScreenSection: { input, provider, configuration in
            try await repository(for: provider, configuration: configuration).retryScreenSection(from: input)
        }
    )

    static let previewValue = LLMClient(
        generateSchema: { _, _, _ in
            UIComponent(
                id: UUID().uuidString,
                type: .vStack,
                props: ComponentProps(spacing: 12, padding: 18, backgroundColor: "#FFF7E8", cornerRadius: 22),
                children: [
                    UIComponent(
                        id: UUID().uuidString,
                        type: .text,
                        props: ComponentProps(text: "Generated preview", foregroundColor: "#0D111A"),
                        children: nil,
                        capability: nil
                    ),
                    UIComponent(
                        id: UUID().uuidString,
                        type: .button,
                        props: ComponentProps(text: "Continue", foregroundColor: "#FFFFFF", backgroundColor: "#FF8533", cornerRadius: 14),
                        children: nil,
                        capability: nil
                    )
                ],
                capability: nil
            )
        },
        generateScreenPlan: { _, _, _ in
            previewScreenPlan
        },
        generateScreenSection: { input, _, _ in
            previewSection(for: input)
        },
        retryScreenSection: { input, _, _ in
            previewSection(for: input)
        }
    )

    static let testValue = LLMClient(
        generateSchema: { _, _, _ in
            UIComponent(
                id: UUID().uuidString,
                type: .text,
                props: ComponentProps(text: "Test schema"),
                children: nil,
                capability: nil
            )
        },
        generateScreenPlan: { _, _, _ in
            previewScreenPlan
        },
        generateScreenSection: { input, _, _ in
            previewSection(for: input)
        },
        retryScreenSection: { input, _, _ in
            previewSection(for: input)
        }
    )

    private static func repository(
        for provider: LLMProvider,
        configuration: CustomEndpointConfiguration
    ) throws -> LLMRepository {
        switch provider {
        case .openRouter:
            return try OpenAICompatibleLLMRepository(
                configuration: configuration,
                providerName: "OpenRouter"
            )
        case .openAI:
            return try OpenAICompatibleLLMRepository(
                configuration: configuration,
                providerName: "OpenAI"
            )
        case .gemini:
            return try GeminiLLMRepository(configuration: configuration)
        case .customEndpoint:
            switch configuration.providerFormat {
            case .openAICompatible:
                return try OpenAICompatibleLLMRepository(
                    configuration: configuration,
                    providerName: "Custom API"
                )
            case .gemini:
                return try GeminiLLMRepository(configuration: configuration)
            case .ollamaCompatible:
                return OllamaLLMRepository()
            }
        case .localOllama:
            return OllamaLLMRepository()
        }
    }

    private static let previewScreenPlan = ScreenPlan(
        purpose: "Preview a generated screen plan",
        rootLayout: .scrollView,
        style: ScreenStyleHints(
            tone: "warm native",
            backgroundColor: "#FFF7E8",
            accentColor: "#FF8533",
            typography: "rounded"
        ),
        sections: [
            ScreenSectionPlan(
                id: "preview-header",
                title: "Header",
                purpose: "Introduce the screen",
                kind: .header
            ),
            ScreenSectionPlan(
                id: "preview-actions",
                title: "Actions",
                purpose: "Show the primary call to action",
                kind: .actions
            )
        ]
    )

    private static func previewSection(for input: ScreenSectionGenerationInput) -> UIComponent {
        UIComponent(
            id: input.section.id,
            type: .section,
            props: ComponentProps(spacing: 12, padding: 16),
            children: [
                UIComponent(
                    id: "\(input.section.id)-title",
                    type: .text,
                    props: ComponentProps(
                        text: input.section.title,
                        foregroundColor: "#0D111A",
                        fontSize: 16,
                        fontWeight: "semibold",
                        textRole: "subtitle"
                    ),
                    children: nil,
                    capability: nil
                )
            ],
            capability: nil
        )
    }
}

extension DependencyValues {
    var llmClient: LLMClient {
        get { self[LLMClient.self] }
        set { self[LLMClient.self] = newValue }
    }
}
