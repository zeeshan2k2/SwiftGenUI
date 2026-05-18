//
//  DynamicUIFeature.swift
//  SwiftGenUI
//
//  TCA feature for prompt-driven UI generation.
//

import ComposableArchitecture
import Foundation

@Reducer
struct DynamicUIFeature {
    @Dependency(\.llmClient) private var llmClient

    @ObservableState
    struct State: Equatable {
        var prompt = ""
        var selectedExample: String?
        var generationStatus = "Ready"
        var generatedSchema: String?
        var generatedComponent: UIComponent?
        var generationHistory: [HistoryItem] = []
        var isGenerating = false
        var isPreviewPresented = false
        var isSchemaInspectorPresented = false

        struct HistoryItem: Identifiable, Equatable {
            let id: String
            let prompt: String
            let component: UIComponent
            let schema: String
        }

        let examples = [
            "Signup form",
            "Profile card",
            "Task form",
            "Settings screen"
        ]

        let examplePrompts = [
            "Signup form": "Create a signup form with a title, email field, password field, and an orange continue button.",
            "Profile card": "Create a profile card with an avatar placeholder, name, subtitle, and a follow button.",
            "Task form": "Create a task form with title, due date, priority selector, and a bottom save button.",
            "Settings screen": "Create a settings screen with account, notifications, privacy rows, and a sign out button."
        ]
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case exampleSelected(String)
        case generateTapped
        case cancelGenerationTapped
        case historySelected(String)
        case historyDeleteTapped(String)
        case schemaResponseReceived(Result<UIComponent, GenerationError>)
    }

    private static let generationCancelID = "dynamic-ui-generation"

    enum GenerationError: Error, Equatable {
        case emptyResponse
        case invalidSchema
        case requestFailed(String)

        var message: String {
            switch self {
            case .emptyResponse:
                return "Ollama returned an empty response"
            case .invalidSchema:
                return "Ollama returned invalid schema"
            case let .requestFailed(message):
                return message
            }
        }
    }

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case let .exampleSelected(example):
                state.selectedExample = example
                state.prompt = state.examplePrompts[example] ?? example
                state.generationStatus = "Example loaded"
                state.generatedComponent = nil
                state.generatedSchema = nil
                state.isPreviewPresented = false
                state.isSchemaInspectorPresented = false
                return .none

            case .generateTapped:
                let prompt = state.prompt.trimmingCharacters(in: .whitespacesAndNewlines)

                guard !prompt.isEmpty else {
                    state.generationStatus = "Add a prompt first"
                    return .none
                }

                state.isGenerating = true
                state.isPreviewPresented = false
                state.isSchemaInspectorPresented = false
                state.generationStatus = "Generating with Qwen"
                state.generatedComponent = nil
                state.generatedSchema = nil

                return .run { send in
                    do {
                        let component = try await llmClient.generateSchema(prompt)
                        try SchemaValidator().validate(component)
                        await send(.schemaResponseReceived(.success(component)))
                    } catch is ValidationError {
                        await send(.schemaResponseReceived(.failure(.invalidSchema)))
                    } catch let error as GenerationError {
                        await send(.schemaResponseReceived(.failure(error)))
                    } catch {
                        await send(.schemaResponseReceived(.failure(.requestFailed(error.localizedDescription))))
                    }
                }
                .cancellable(id: Self.generationCancelID, cancelInFlight: true)

            case .cancelGenerationTapped:
                state.isGenerating = false
                state.generatedComponent = nil
                state.generatedSchema = nil
                state.isPreviewPresented = false
                state.isSchemaInspectorPresented = false
                state.generationStatus = "Generation cancelled"
                return .cancel(id: Self.generationCancelID)

            case let .historySelected(id):
                guard let item = state.generationHistory.first(where: { $0.id == id }) else {
                    return .none
                }

                state.generatedComponent = item.component
                state.generatedSchema = item.schema
                state.generationStatus = "Loaded from history"
                state.isSchemaInspectorPresented = false
                state.isPreviewPresented = true
                return .none

            case let .historyDeleteTapped(id):
                state.generationHistory.removeAll { $0.id == id }
                return .none

            case let .schemaResponseReceived(.success(component)):
                let schema = Self.prettyPrintedJSON(for: component)

                state.isGenerating = false
                state.generatedComponent = component
                state.generatedSchema = schema
                state.generationStatus = "Schema received"
                state.generationHistory.insert(
                    State.HistoryItem(
                        id: UUID().uuidString,
                        prompt: state.prompt.trimmingCharacters(in: .whitespacesAndNewlines),
                        component: component,
                        schema: schema
                    ),
                    at: 0
                )
                state.isPreviewPresented = true
                return .none

            case let .schemaResponseReceived(.failure(error)):
                state.isGenerating = false
                state.generatedComponent = nil
                state.generatedSchema = nil
                state.isPreviewPresented = false
                state.isSchemaInspectorPresented = false
                state.generationStatus = error.message
                return .none
            }
        }
    }

    private static func prettyPrintedJSON(for component: UIComponent) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(component),
              let json = String(data: data, encoding: .utf8) else {
            return "Schema generated, but could not be formatted."
        }

        return json
    }
}
