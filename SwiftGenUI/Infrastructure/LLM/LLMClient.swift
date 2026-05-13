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
}

extension LLMClient: DependencyKey {
    static let liveValue = LLMClient { prompt in
        try await OllamaClient().generateSchema(from: prompt)
    }

    static let previewValue = LLMClient { _ in
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
    }

    static let testValue = LLMClient { _ in
        UIComponent(
            id: UUID().uuidString,
            type: .text,
            props: ComponentProps(text: "Test schema"),
            children: nil,
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
