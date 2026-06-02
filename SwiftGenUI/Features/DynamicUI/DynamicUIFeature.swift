
import ComposableArchitecture
import Foundation

@Reducer
struct DynamicUIFeature {
    @Dependency(\.llmClient) private var llmClient
    @Dependency(\.historyClient) private var historyClient

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
        var hasLoadedPersistedHistory = false
        var isPreviewPresented = false
        var isSchemaInspectorPresented = false
        var isModelPickerPresented = false
        var configuredProvider: LLMProvider?
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

        var generationErrorMessage: String? {
            guard case let .failed(message) = generationPhase else {
                return nil
            }

            return message
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
        case viewAppeared
        case historyLoaded([State.HistoryItem])
        case exampleSelected(String)
        case generateTapped
        case cancelGenerationTapped
        case modelButtonTapped
        case modelPickerDismissed
        case providerSelected(LLMProvider)
        case providerConfigureTapped(LLMProvider)
        case providerConfigDismissed
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
        case localOllamaUnavailable
        case requestFailed(String)

        var message: String {
            switch self {
            case .emptyResponse:
                return "The provider returned an empty response. Try again."
            case .invalidSchema:
                return "The AI response could not be turned into a valid UI. Try simplifying the prompt."
            case .noValidSections:
                return "The AI could not generate enough valid sections. Try a shorter prompt."
            case .localOllamaUnavailable:
                return "Local Ollama is not running. Start Ollama and try again."
            case let .requestFailed(message):
                return Self.userFriendlyMessage(for: message)
            }
        }

        private static func userFriendlyMessage(for rawMessage: String) -> String {
            let message = rawMessage.trimmingCharacters(in: .whitespacesAndNewlines)
            let lowercasedMessage = message.lowercased()

            if lowercasedMessage.contains("missing") && lowercasedMessage.contains("api key") {
                return "This provider needs an API key before it can generate UI."
            }

            if lowercasedMessage.contains("localhost") ||
                lowercasedMessage.contains("ollama") {
                return "Local Ollama is not running. Start Ollama and try again."
            }

            if lowercasedMessage.contains("timed out") ||
                lowercasedMessage.contains("timeout") {
                return "Generation took too long. Try a shorter prompt or another provider."
            }

            if lowercasedMessage.contains("401") ||
                lowercasedMessage.contains("403") ||
                lowercasedMessage.contains("unauthorized") ||
                lowercasedMessage.contains("forbidden") ||
                lowercasedMessage.contains("api key was rejected") {
                return "The API key was rejected. Check your provider settings."
            }

            if lowercasedMessage.contains("429") ||
                lowercasedMessage.contains("rate") ||
                lowercasedMessage.contains("quota") ||
                lowercasedMessage.contains("insufficient_quota") {
                return "This provider is temporarily rate limited or out of quota. Try again shortly or switch providers."
            }

            if lowercasedMessage.contains("404") ||
                lowercasedMessage.contains("no endpoints") ||
                lowercasedMessage.contains("model") && lowercasedMessage.contains("unavailable") {
                return "This model is unavailable right now. Try another model or provider."
            }

            if lowercasedMessage.contains("hostname could not be found") ||
                lowercasedMessage.contains("could not connect to the server") ||
                lowercasedMessage.contains("not connected to the internet") ||
                lowercasedMessage.contains("network connection was lost") ||
                lowercasedMessage.contains("dns") {
                return "Could not reach the selected AI provider. Check your connection and try again."
            }

            if lowercasedMessage.contains("not valid json") ||
                lowercasedMessage.contains("invalid json") ||
                lowercasedMessage.contains("correct format") ||
                lowercasedMessage.contains("unexpected end of file") {
                return "The AI response could not be turned into a valid UI. Try simplifying the prompt."
            }

            if lowercasedMessage.contains("empty response") {
                return "The provider returned an empty response. Try again."
            }

            return message.isEmpty
                ? "Something went wrong while generating the UI. Please try again."
                : "Something went wrong while generating the UI. Please try again."
        }
    }

    private static func generationError(from error: Error, provider: LLMProvider) -> GenerationError {
        if let generationError = error as? GenerationError {
            return generationError
        }

        let nsError = error as NSError
        let message = error.localizedDescription.lowercased()
        let isTransportFailure = nsError.domain == NSURLErrorDomain ||
            message.contains("could not connect to the server") ||
            message.contains("connection refused")

        if provider == .localOllama, isTransportFailure {
            return .localOllamaUnavailable
        }

        return .requestFailed(error.localizedDescription)
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

            case .viewAppeared:
                guard !state.hasLoadedPersistedHistory else {
                    return .none
                }

                state.hasLoadedPersistedHistory = true

                return .run { send in
                    do {
                        let persistedItems = try await historyClient.loadHistory()
                        let historyItems = await Self.historyItems(from: persistedItems)
                        await send(.historyLoaded(historyItems))
                    } catch {
                        printHistoryPersistenceFailure(error, operation: "load")
                    }
                }

            case let .historyLoaded(items):
                let existingIDs = Set(state.generationHistory.map(\.id))
                state.generationHistory.append(contentsOf: items.filter { !existingIDs.contains($0.id) })
                return .none

            case .modelButtonTapped:
                state.isModelPickerPresented = true
                return .none

            case .modelPickerDismissed:
                state.configuredProvider = nil
                return .none

            case let .providerConfigureTapped(provider):
                state.configuredProvider = provider
                return .none

            case .providerConfigDismissed:
                state.configuredProvider = nil
                return .none

            case let .providerSelected(provider):
                state.selectedProvider = provider
                if provider != .customEndpoint {
                    state.customEndpointConfiguration = LLMProviderConfigurationResolver.configuration(
                        for: provider,
                        currentConfiguration: provider.defaultConfiguration
                    )
                }
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

                let provider = state.selectedProvider
                let providerConfiguration = LLMProviderConfigurationResolver.configuration(
                    for: provider,
                    currentConfiguration: state.customEndpointConfiguration
                )

                switch state.generationMode {
                case .multiStage:
                    state.generationPhase = .planningScreen

                    return .run { send in
                        do {
                            let plan = try await llmClient.generateScreenPlan(prompt, provider, providerConfiguration)
                            await send(.screenPlanResponseReceived(.success(plan)))
                        } catch let error as GenerationError {
                            printGenerationFailure(error, context: "screen planning")
                            await send(.screenPlanResponseReceived(.failure(error)))
                        } catch {
                            printGenerationFailure(error, context: "screen planning")
                            await send(.screenPlanResponseReceived(.failure(Self.generationError(
                                from: error,
                                provider: provider
                            ))))
                        }
                    }
                    .cancellable(id: Self.generationCancelID, cancelInFlight: true)

                case .singleSchema:
                    state.generationPhase = .generatingSingleSchema

                    return .run { send in
                        do {
                            let component = try await llmClient.generateSchema(prompt, provider, providerConfiguration)
                            await send(.singleSchemaGenerated(component))
                        } catch let error as GenerationError {
                            printGenerationFailure(error, context: "single schema generation")
                            await send(.schemaResponseReceived(.failure(error)))
                        } catch {
                            printGenerationFailure(error, context: "single schema generation")
                            await send(.schemaResponseReceived(.failure(Self.generationError(
                                from: error,
                                provider: provider
                            ))))
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
                return .run { _ in
                    do {
                        try await historyClient.deleteHistoryItem(id)
                    } catch {
                        printHistoryPersistenceFailure(error, operation: "delete", id: id)
                    }
                }

            case let .screenPlanResponseReceived(.success(plan)):
                state.plannedScreen = plan
                state.generatedSections = []
                state.generationPhase = .screenPlanReady

                let prompt = state.prompt.trimmingCharacters(in: .whitespacesAndNewlines)
                let provider = state.selectedProvider
                let providerConfiguration = LLMProviderConfigurationResolver.configuration(
                    for: provider,
                    currentConfiguration: state.customEndpointConfiguration
                )

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
                            generate: { input in
                                try await llmClient.generateScreenSection(input, provider, providerConfiguration)
                            },
                            retry: { input in
                                try await llmClient.retryScreenSection(input, provider, providerConfiguration)
                            }
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
                        await send(.screenSectionsResponseReceived(.failure(Self.generationError(
                            from: error,
                            provider: provider
                        ))))
                    }
                }
                .cancellable(id: Self.generationCancelID, cancelInFlight: true)

            case let .screenPlanResponseReceived(.failure(error)):
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
                state.generationPhase = .failed(error.message)
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
                state.generationPhase = .failed(error.message)
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
                let duration = state.generationStartedAt.map { Date().timeIntervalSince($0) }
                let historyItem = State.HistoryItem(
                    id: UUID().uuidString,
                    prompt: state.prompt.trimmingCharacters(in: .whitespacesAndNewlines),
                    component: component,
                    schema: schema,
                    warning: state.generationWarning,
                    generationDuration: duration
                )

                state.generationPhase = .completed
                state.plannedScreen = nil
                state.generatedSections = []
                state.generatedComponent = component
                state.generatedSchema = schema
                state.completedGenerationDuration = duration
                state.generationStartedAt = nil
                state.generationHistory.insert(historyItem, at: 0)
                state.isPreviewPresented = true
                return .run { _ in
                    do {
                        try await historyClient.saveHistoryItem(PersistedHistoryItem(
                            id: historyItem.id,
                            prompt: historyItem.prompt,
                            schema: historyItem.schema,
                            warning: historyItem.warning,
                            generationDuration: historyItem.generationDuration,
                            createdAt: Date()
                        ))
                    } catch {
                        printHistoryPersistenceFailure(error, operation: "save", id: historyItem.id)
                    }
                }

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

    private static func historyItems(from persistedItems: [PersistedHistoryItem]) -> [State.HistoryItem] {
        let decoder = JSONDecoder()

        return persistedItems.compactMap { item in
            guard let data = item.schema.data(using: .utf8) else {
                return nil
            }

            do {
                let component = try decoder.decode(UIComponent.self, from: data)
                return State.HistoryItem(
                    id: item.id,
                    prompt: item.prompt,
                    component: component,
                    schema: item.schema,
                    warning: item.warning,
                    generationDuration: item.generationDuration
                )
            } catch {
                printHistoryPersistenceFailure(error, operation: "decode", id: item.id)
                return nil
            }
        }
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

nonisolated private func printHistoryPersistenceFailure(
    _ error: Error,
    operation: String,
    id: String? = nil
) {
    #if DEBUG
    let idText = id.map { " id=\($0)" } ?? ""
    print("SwiftGenUI history \(operation) failed.\(idText) error=\(error.localizedDescription)")
    print("SwiftGenUI history \(operation) debug details: \(String(reflecting: error))")
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
