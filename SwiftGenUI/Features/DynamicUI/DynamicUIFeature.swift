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
        var generationMode: GenerationMode = .singleSchema
        var generationPhase: GenerationPhase = .idle
        var plannedScreen: ScreenPlan?
        var generatedSections: [UIComponent] = []
        var generatedSchema: String?
        var generatedComponent: UIComponent?
        var generationWarning: String?
        var generationStartedAt: Date?
        var completedGenerationDuration: TimeInterval?
        var generationHistory: [HistoryItem] = []
        var isPreviewPresented = false
        var isSchemaInspectorPresented = false
        var isModelPickerPresented = false
        var selectedProvider: LLMProvider = .localOllama
        var customEndpointConfiguration = CustomEndpointConfiguration()

        var providerButtonTitle: String {
            selectedProvider.title
        }

        var generationStatus: String {
            generationPhase.statusText
        }

        var isGenerating: Bool {
            generationPhase.isGenerating
        }

        var completedGenerationDurationText: String? {
            guard let completedGenerationDuration else {
                return nil
            }

            return "Rendered in \(Self.formattedDuration(completedGenerationDuration))"
        }

        struct HistoryItem: Identifiable, Equatable {
            let id: String
            let prompt: String
            let component: UIComponent
            let schema: String
            let warning: String?
            let generationDuration: TimeInterval?
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

        private static func formattedDuration(_ duration: TimeInterval) -> String {
            if duration < 10 {
                return String(format: "%.1fs", duration)
            }

            if duration < 60 {
                return "\(Int(duration.rounded()))s"
            }

            let minutes = Int(duration / 60)
            let seconds = Int(duration.truncatingRemainder(dividingBy: 60).rounded())
            return "\(minutes)m \(seconds)s"
        }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case exampleSelected(String)
        case generateTapped
        case cancelGenerationTapped
        case modelButtonTapped
        case providerSelected(LLMProvider)
        case historySelected(String)
        case historyDeleteTapped(String)
        case screenPlanResponseReceived(Result<ScreenPlan, GenerationError>)
        case sectionGenerationStarted(String)
        case sectionProgressUpdated(String)
        case sectionRetryStarted(String)
        case screenSectionsResponseReceived(Result<GeneratedSections, GenerationError>)
        case singleSchemaGenerated(UIComponent)
        case mergedSchemaResponseReceived(Result<UIComponent, GenerationError>)
        case finalSchemaValidated(UIComponent)
        case schemaResponseReceived(Result<UIComponent, GenerationError>)
    }

    enum GenerationMode: Equatable {
        case singleSchema
        case multiStage
    }

    nonisolated enum LLMProvider: String, Equatable, CaseIterable, Sendable {
        case localOllama
        case customEndpoint

        var title: String {
            switch self {
            case .localOllama:
                return "Local Qwen"
            case .customEndpoint:
                return "Custom API"
            }
        }
    }

    nonisolated enum ProviderFormat: String, Equatable, CaseIterable, Sendable {
        case openAICompatible
        case ollamaCompatible

        var title: String {
            switch self {
            case .openAICompatible:
                return "OpenAI-compatible"
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

    enum GenerationPhase: Equatable {
        case idle
        case promptRequired
        case exampleLoaded
        case generatingSingleSchema
        case planningScreen
        case screenPlanReady
        case generatingSection(String)
        case retryingSection(String)
        case sectionsReady
        case mergingSections
        case validatingSchema
        case finishing
        case completed
        case cancelled
        case loadedFromHistory
        case failed(String)

        var isGenerating: Bool {
            switch self {
            case .generatingSingleSchema,
                 .planningScreen,
                 .generatingSection,
                 .retryingSection,
                 .mergingSections,
                 .validatingSchema,
                 .finishing:
                return true
            case .idle,
                 .promptRequired,
                 .exampleLoaded,
                 .screenPlanReady,
                 .sectionsReady,
                 .completed,
                 .cancelled,
                 .loadedFromHistory,
                 .failed:
                return false
            }
        }

        var statusText: String {
            switch self {
            case .idle:
                return "Ready"
            case .promptRequired:
                return "Add a prompt first"
            case .exampleLoaded:
                return "Example loaded"
            case .generatingSingleSchema:
                return "Generating UI..."
            case .planningScreen:
                return "Planning screen..."
            case .screenPlanReady:
                return "Screen plan ready"
            case let .generatingSection(section):
                return "Generating \(section)..."
            case let .retryingSection(section):
                return "Retrying \(section)..."
            case .sectionsReady:
                return "Sections generated"
            case .mergingSections:
                return "Merging sections..."
            case .validatingSchema:
                return "Validating UI..."
            case .finishing:
                return "Finishing preview..."
            case .completed:
                return "UI rendered"
            case .cancelled:
                return "Generation cancelled"
            case .loadedFromHistory:
                return "Loaded from history"
            case let .failed(message):
                return message
            }
        }

        var buttonTitle: String {
            isGenerating ? statusText : "Generate Native UI"
        }
    }

    private static let generationCancelID = "dynamic-ui-generation"

    enum GenerationError: Error, Equatable {
        case emptyResponse
        case invalidSchema
        case noValidSections
        case requestFailed(String)

        var message: String {
            switch self {
            case .emptyResponse:
                return "Ollama returned an empty response"
            case .invalidSchema:
                return "Ollama returned invalid schema"
            case .noValidSections:
                return "No valid sections were generated after retry"
            case let .requestFailed(message):
                return message
            }
        }
    }

    struct GeneratedSections: Equatable {
        let components: [UIComponent]
        let warning: String?
    }

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .modelButtonTapped:
                state.isModelPickerPresented = true
                return .none

            case let .providerSelected(provider):
                state.selectedProvider = provider
                return .none

            case let .exampleSelected(example):
                state.selectedExample = example
                state.prompt = state.examplePrompts[example] ?? example
                state.generationMode = .singleSchema
                state.generationPhase = .exampleLoaded
                state.plannedScreen = nil
                state.generatedSections = []
                state.generatedComponent = nil
                state.generatedSchema = nil
                state.generationWarning = nil
                state.generationStartedAt = nil
                state.completedGenerationDuration = nil
                state.isPreviewPresented = false
                state.isSchemaInspectorPresented = false
                return .none

            case .generateTapped:
                let prompt = state.prompt.trimmingCharacters(in: .whitespacesAndNewlines)

                guard !prompt.isEmpty else {
                    state.generationPhase = .promptRequired
                    return .none
                }

                state.generationMode = Self.generationMode(for: prompt)
                state.isPreviewPresented = false
                state.isSchemaInspectorPresented = false
                state.plannedScreen = nil
                state.generatedSections = []
                state.generatedComponent = nil
                state.generatedSchema = nil
                state.generationWarning = nil
                state.generationStartedAt = Date()
                state.completedGenerationDuration = nil

                switch state.generationMode {
                case .multiStage:
                    state.generationPhase = .planningScreen

                    return .run { send in
                        do {
                            let plan = try await llmClient.generateScreenPlan(prompt)
                            await send(.screenPlanResponseReceived(.success(plan)))
                        } catch let error as GenerationError {
                            printGenerationFailure(error, context: "screen planning")
                            await send(.screenPlanResponseReceived(.failure(error)))
                        } catch {
                            printGenerationFailure(error, context: "screen planning")
                            await send(.screenPlanResponseReceived(.failure(.requestFailed(error.localizedDescription))))
                        }
                    }
                    .cancellable(id: Self.generationCancelID, cancelInFlight: true)

                case .singleSchema:
                    state.generationPhase = .generatingSingleSchema

                    return .run { send in
                        do {
                            let component = try await llmClient.generateSchema(prompt)
                            await send(.singleSchemaGenerated(component))
                        } catch let error as GenerationError {
                            printGenerationFailure(error, context: "single schema generation")
                            await send(.schemaResponseReceived(.failure(error)))
                        } catch {
                            printGenerationFailure(error, context: "single schema generation")
                            await send(.schemaResponseReceived(.failure(.requestFailed(error.localizedDescription))))
                        }
                    }
                    .cancellable(id: Self.generationCancelID, cancelInFlight: true)
                }

            case .cancelGenerationTapped:
                state.generationPhase = .cancelled
                state.plannedScreen = nil
                state.generatedSections = []
                state.generatedComponent = nil
                state.generatedSchema = nil
                state.generationWarning = nil
                state.generationStartedAt = nil
                state.completedGenerationDuration = nil
                state.isPreviewPresented = false
                state.isSchemaInspectorPresented = false
                return .cancel(id: Self.generationCancelID)

            case let .historySelected(id):
                guard let item = state.generationHistory.first(where: { $0.id == id }) else {
                    return .none
                }

                state.generatedComponent = item.component
                state.generatedSchema = item.schema
                state.generationWarning = item.warning
                state.generationStartedAt = nil
                state.completedGenerationDuration = item.generationDuration
                state.plannedScreen = nil
                state.generatedSections = []
                state.generationPhase = .loadedFromHistory
                state.isSchemaInspectorPresented = false
                state.isPreviewPresented = true
                return .none

            case let .historyDeleteTapped(id):
                state.generationHistory.removeAll { $0.id == id }
                return .none

            case let .screenPlanResponseReceived(.success(plan)):
                state.plannedScreen = plan
                state.generatedSections = []
                state.generationPhase = .screenPlanReady

                let prompt = state.prompt.trimmingCharacters(in: .whitespacesAndNewlines)

                return .run { send in
                    do {
                        await send(.sectionGenerationStarted(plan.sections.first?.progressLabel ?? "content"))

                        var sectionInputs: [ScreenSectionGenerationInput] = []
                        for section in plan.sections {
                            let input = await ScreenSectionGenerationInput(
                                userPrompt: prompt,
                                plan: plan,
                                section: section
                            )
                            sectionInputs.append(input)
                        }

                        let outcomes = try await Self.generateSectionsConcurrently(
                            sectionInputs,
                            send: send,
                            generate: llmClient.generateScreenSection,
                            retry: llmClient.retryScreenSection
                        )
                        let orderedOutcomes = outcomes.sorted { $0.index < $1.index }
                        let sections = orderedOutcomes.compactMap(\.component)
                        let skippedSectionTitles = orderedOutcomes
                            .filter { $0.component == nil }
                            .map(\.title)

                        guard !sections.isEmpty else {
                            await send(.screenSectionsResponseReceived(.failure(.noValidSections)))
                            return
                        }

                        let warning = await Self.partialScreenWarning(for: skippedSectionTitles)
                        await send(.screenSectionsResponseReceived(.success(
                            GeneratedSections(components: sections, warning: warning)
                        )))
                    } catch let error as ValidationError {
                        printGenerationFailure(error, context: "section generation")
                        await send(.screenSectionsResponseReceived(.failure(.invalidSchema)))
                    } catch let error as GenerationError {
                        printGenerationFailure(error, context: "section generation")
                        await send(.screenSectionsResponseReceived(.failure(error)))
                    } catch {
                        printGenerationFailure(error, context: "section generation")
                        await send(.screenSectionsResponseReceived(.failure(.requestFailed(error.localizedDescription))))
                    }
                }
                .cancellable(id: Self.generationCancelID, cancelInFlight: true)

            case let .screenPlanResponseReceived(.failure(error)):
                state.generationPhase = .failed("Screen planning failed: \(error.message)")
                state.plannedScreen = nil
                state.generatedSections = []
                state.generatedComponent = nil
                state.generatedSchema = nil
                state.generationWarning = nil
                state.generationStartedAt = nil
                state.completedGenerationDuration = nil
                state.isPreviewPresented = false
                state.isSchemaInspectorPresented = false
                return .none

            case let .sectionGenerationStarted(section):
                state.generationPhase = .generatingSection(section)
                return .none

            case let .sectionProgressUpdated(section):
                state.generationPhase = .generatingSection(section)
                return .none

            case let .sectionRetryStarted(sectionTitle):
                state.generationPhase = .retryingSection(sectionTitle)
                return .none

            case let .screenSectionsResponseReceived(.success(result)):
                guard let plan = state.plannedScreen else {
                    state.generationPhase = .failed("Screen plan missing before merge")
                    state.generatedSections = []
                    return .none
                }

                state.generatedSections = result.components
                state.generationWarning = result.warning
                state.generationPhase = .mergingSections

                return .run { send in
                    do {
                        let mergedComponent = await Self.mergeSections(result.components, using: plan)
                        await send(.mergedSchemaResponseReceived(.success(mergedComponent)))
                    }
                }
                .cancellable(id: Self.generationCancelID, cancelInFlight: true)

            case let .screenSectionsResponseReceived(.failure(error)):
                state.generationPhase = .failed("Section generation failed: \(error.message)")
                state.generatedSections = []
                state.generatedComponent = nil
                state.generatedSchema = nil
                state.generationWarning = nil
                state.generationStartedAt = nil
                state.completedGenerationDuration = nil
                state.isPreviewPresented = false
                state.isSchemaInspectorPresented = false
                return .none

            case let .singleSchemaGenerated(component):
                state.generationPhase = .validatingSchema

                return .run { send in
                    do {
                        try await SchemaValidator().validate(component)
                        await send(.finalSchemaValidated(component))
                    } catch let error as ValidationError {
                        printGenerationFailure(error, context: "single schema validation")
                        await send(.schemaResponseReceived(.failure(.invalidSchema)))
                    } catch let error as GenerationError {
                        printGenerationFailure(error, context: "single schema validation")
                        await send(.schemaResponseReceived(.failure(error)))
                    } catch {
                        printGenerationFailure(error, context: "single schema validation")
                        await send(.schemaResponseReceived(.failure(.requestFailed(error.localizedDescription))))
                    }
                }
                .cancellable(id: Self.generationCancelID, cancelInFlight: true)

            case let .mergedSchemaResponseReceived(.success(component)):
                state.generationPhase = .validatingSchema

                return .run { send in
                    do {
                        try await SchemaValidator().validate(component)
                        await send(.finalSchemaValidated(component))
                    } catch let error as ValidationError {
                        printGenerationFailure(error, context: "merged schema validation")
                        await send(.schemaResponseReceived(.failure(.invalidSchema)))
                    } catch let error as GenerationError {
                        printGenerationFailure(error, context: "merged schema validation")
                        await send(.schemaResponseReceived(.failure(error)))
                    } catch {
                        printGenerationFailure(error, context: "merged schema validation")
                        await send(.schemaResponseReceived(.failure(.requestFailed(error.localizedDescription))))
                    }
                }
                .cancellable(id: Self.generationCancelID, cancelInFlight: true)

            case let .mergedSchemaResponseReceived(.failure(error)):
                state.generationPhase = .failed("Schema merge failed: \(error.message)")
                state.generatedSections = []
                state.generatedComponent = nil
                state.generatedSchema = nil
                state.generationWarning = nil
                state.generationStartedAt = nil
                state.completedGenerationDuration = nil
                state.isPreviewPresented = false
                state.isSchemaInspectorPresented = false
                return .none

            case let .finalSchemaValidated(component):
                state.generationPhase = .finishing

                return .run { send in
                    await Task.yield()
                    await send(.schemaResponseReceived(.success(component)))
                }
                .cancellable(id: Self.generationCancelID, cancelInFlight: true)

            case let .schemaResponseReceived(.success(component)):
                let schema = Self.prettyPrintedJSON(for: component)

                state.generationPhase = .completed
                state.plannedScreen = nil
                state.generatedSections = []
                state.generatedComponent = component
                state.generatedSchema = schema
                let duration = state.generationStartedAt.map { Date().timeIntervalSince($0) }
                state.completedGenerationDuration = duration
                state.generationStartedAt = nil
                state.generationHistory.insert(
                    State.HistoryItem(
                        id: UUID().uuidString,
                        prompt: state.prompt.trimmingCharacters(in: .whitespacesAndNewlines),
                        component: component,
                        schema: schema,
                        warning: state.generationWarning,
                        generationDuration: duration
                    ),
                    at: 0
                )
                state.isPreviewPresented = true
                return .none

            case let .schemaResponseReceived(.failure(error)):
                state.generationPhase = .failed(error.message)
                state.plannedScreen = nil
                state.generatedSections = []
                state.generatedComponent = nil
                state.generatedSchema = nil
                state.generationWarning = nil
                state.generationStartedAt = nil
                state.completedGenerationDuration = nil
                state.isPreviewPresented = false
                state.isSchemaInspectorPresented = false
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

    private static func mergeSections(_ sections: [UIComponent], using plan: ScreenPlan) -> UIComponent {
        UIComponent(
            id: "root",
            type: plan.rootLayout.componentType,
            props: ComponentProps(
                spacing: 18,
                padding: 20,
                backgroundColor: plan.style.backgroundColor
            ),
            children: sections,
            capability: nil
        )
    }

    private static func partialScreenWarning(for skippedSectionTitles: [String]) -> String? {
        guard !skippedSectionTitles.isEmpty else {
            return nil
        }

        let sectionNames = skippedSectionTitles.joined(separator: ", ")
        return "Partial screen rendered. These sections could not be generated after retry: \(sectionNames)."
    }

    private static func generateValidatedSection(
        _ input: ScreenSectionGenerationInput,
        send: Send<Action>,
        generate: @escaping (ScreenSectionGenerationInput) async throws -> UIComponent,
        retry: @escaping (ScreenSectionGenerationInput) async throws -> UIComponent
    ) async throws -> UIComponent {
        do {
            let component = try await generate(input)
            try SchemaValidator().validate(component)
            return component
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            try Task.checkCancellation()
            send(.sectionRetryStarted(input.section.title))

            let component = try await retry(input)
            try SchemaValidator().validate(component)
            return component
        }
    }

    private static func generateSectionsConcurrently(
        _ inputs: [ScreenSectionGenerationInput],
        send: Send<Action>,
        generate: @escaping (ScreenSectionGenerationInput) async throws -> UIComponent,
        retry: @escaping (ScreenSectionGenerationInput) async throws -> UIComponent
    ) async throws -> [SectionGenerationOutcome] {
        try await withThrowingTaskGroup(of: SectionGenerationOutcome.self) { group in
            for (index, input) in inputs.enumerated() {
                group.addTask {
                    do {
                        let component = try await generateValidatedSection(
                            input,
                            send: send,
                            generate: generate,
                            retry: retry
                        )
                        return SectionGenerationOutcome(
                            index: index,
                            title: input.section.title,
                            component: component
                        )
                    } catch is CancellationError {
                        throw CancellationError()
                    } catch {
                        return SectionGenerationOutcome(
                            index: index,
                            title: input.section.title,
                            component: nil
                        )
                    }
                }
            }

            var outcomes: [SectionGenerationOutcome] = []
            var completedIndexes: Set<Int> = []

            for try await outcome in group {
                outcomes.append(outcome)
                completedIndexes.insert(outcome.index)

                if let nextInput = inputs.enumerated().first(where: { !completedIndexes.contains($0.offset) })?.element {
                    send(.sectionProgressUpdated(nextInput.section.progressLabel))
                }
            }

            return outcomes
        }
    }

    private static func generationMode(for prompt: String) -> GenerationMode {
        let normalizedPrompt = prompt.lowercased()
        let words = normalizedPrompt.split(whereSeparator: \.isWhitespace)
        let complexScreenTerms = [
            "dashboard",
            "full screen",
            "full-screen",
            "screen with",
            "recent activity",
            "recent transactions",
            "list with",
            "rows",
            "sections"
        ]
        let sectionTerms = [
            "header",
            "card",
            "actions",
            "list",
            "footer",
            "button",
            "fields",
            "rows",
            "stats"
        ]

        let complexTermCount = complexScreenTerms.filter(normalizedPrompt.contains).count
        let requestedSectionCount = sectionTerms.filter(normalizedPrompt.contains).count
        let asksForRepeatedItems = normalizedPrompt.contains("three ")
            || normalizedPrompt.contains("four ")
            || normalizedPrompt.contains("multiple ")
            || normalizedPrompt.contains("each ")

        if complexTermCount > 0 && (words.count >= 16 || requestedSectionCount >= 3) {
            return .multiStage
        }

        if words.count >= 28 && (requestedSectionCount >= 3 || asksForRepeatedItems) {
            return .multiStage
        }

        return .singleSchema
    }
}

private struct SectionGenerationOutcome {
    let index: Int
    let title: String
    let component: UIComponent?
}

nonisolated private func printGenerationFailure(_ error: Error, context: String) {
    #if DEBUG
    print("SwiftGenUI generation failure during \(context): \(error.localizedDescription)")
    print("SwiftGenUI generation failure debug details: \(String(reflecting: error))")
    #endif
}

private extension ScreenSectionPlan {
    var progressLabel: String {
        switch kind {
        case .header:
            return "header"
        case .content:
            return "content"
        case .actions:
            return "actions"
        case .list:
            return "list"
        case .form:
            return "form"
        case .footer:
            return "footer"
        }
    }
}

private extension ScreenRootLayout {
    var componentType: ComponentType {
        switch self {
        case .scrollView:
            return .scrollView
        case .vStack:
            return .vStack
        }
    }
}
