//
//  LLMClient.swift
//  SwiftGenUI
//
//  TCA dependency for prompt-to-schema generation.
//

import ComposableArchitecture
import Foundation

struct LLMClient {
    var generateSchema: (String) async throws -> UIComponent
    var generateScreenPlan: (String) async throws -> ScreenPlan
    var generateScreenSection: (ScreenSectionGenerationInput) async throws -> UIComponent
    var retryScreenSection: (ScreenSectionGenerationInput) async throws -> UIComponent
}

extension LLMClient: DependencyKey {
    static let liveValue = LLMClient(
        generateSchema: { prompt in
            try await OllamaClient().generateSchema(from: prompt)
        },
        generateScreenPlan: { prompt in
            try await OllamaClient().generateScreenPlan(from: prompt)
        },
        generateScreenSection: { input in
            try await OllamaClient().generateScreenSection(from: input)
        },
        retryScreenSection: { input in
            try await OllamaClient().retryScreenSection(from: input)
        }
    )

    static let previewValue = LLMClient(
        generateSchema: { _ in
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
        generateScreenPlan: { _ in
            previewScreenPlan
        },
        generateScreenSection: { input in
            previewSection(for: input)
        },
        retryScreenSection: { input in
            previewSection(for: input)
        }
    )

    static let testValue = LLMClient(
        generateSchema: { _ in
            UIComponent(
                id: UUID().uuidString,
                type: .text,
                props: ComponentProps(text: "Test schema"),
                children: nil,
                capability: nil
            )
        },
        generateScreenPlan: { _ in
            previewScreenPlan
        },
        generateScreenSection: { input in
            previewSection(for: input)
        },
        retryScreenSection: { input in
            previewSection(for: input)
        }
    )

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
