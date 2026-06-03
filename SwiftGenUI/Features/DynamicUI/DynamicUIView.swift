
import ComposableArchitecture
import SwiftUI

struct DynamicUIView: View {
    @Bindable var store: StoreOf<DynamicUIFeature>

    var body: some View {
        NavigationStack {
            ZStack {
                mainBackground

                VStack(alignment: .leading, spacing: AppTheme.cardSpacing) {
                    titleBar
                        .padding(.horizontal, AppTheme.contentPadding)
                        .padding(.top, 18)

                    contentList
                }

                bottomGenerateBar
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $store.isHistoryPresented) {
                GenerationHistoryView(store: store)
            }
            .navigationDestination(isPresented: $store.isPreviewPresented) {
                GeneratedPreviewView(store: store)
            }
            .sheet(
                isPresented: $store.isModelPickerPresented,
                onDismiss: {
                    store.send(.modelPickerDismissed)
                }
            ) {
                ModelProviderSheet(store: store)
                    .presentationDetents([.height(620)])
                    .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            store.send(.viewAppeared)
        }
    }

    private var contentList: some View {
        VStack(alignment: .leading, spacing: AppTheme.cardSpacing) {
            heroCard

            promptComposer
        }
        .padding(.horizontal, AppTheme.contentPadding)
        .padding(.bottom, 112)
    }

    private var titleBar: some View {
        HStack(alignment: .center) {
            Text("SwiftGenUI")
                .font(.system(size: 34, weight: .semibold, design: .default))
                .foregroundStyle(.white)

            Spacer(minLength: 16)

            HStack(spacing: 10) {
                ModelProviderButton(
                    provider: store.selectedProvider
                ) {
                    store.send(.modelButtonTapped)
                }

                HistoryTopButton(count: store.generationHistory.count) {
                    store.send(.historyButtonTapped)
                }
            }
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 7) {
                Text("Current Pipeline")
                    .font(.system(size: 12, weight: .semibold, design: .default))
                    .foregroundStyle(AppTheme.mutedText)

                Text("Prompt to Native UI")
                    .font(.system(size: 28, weight: .semibold, design: .default))
                    .foregroundStyle(.white)

                Text("Schema validated before render")
                    .font(.system(size: 12, weight: .semibold, design: .default))
                    .foregroundStyle(AppTheme.mutedText)
            }

            VStack(spacing: 0) {
                pipelineRow(title: "Renderer", value: "SwiftUI")
                Divider()
                    .overlay(.white.opacity(0.08))
                pipelineRow(title: "Provider", value: store.selectedProvider.pipelineValue)
            }
        }
        .padding(16)
        .background(Color(hex: "#121A20"), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(.white.opacity(0.055), lineWidth: 1)
        }
    }

    private var promptComposer: some View {
        AppCard(opacity: 0.065, strokeOpacity: 0.075) {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Compose")
                            .font(.system(size: 12, weight: .semibold, design: .default))
                            .foregroundStyle(AppTheme.mutedText)

                        Text("What do you want to build?")
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 15, weight: .semibold, design: .default))
                        .foregroundStyle(.white.opacity(0.92))
                        .frame(width: 34, height: 34)
                        .background(
                            Color(hex: "#303840"),
                            in: RoundedRectangle(cornerRadius: 11)
                        )
                        .shadow(color: Color.black.opacity(0.22), radius: 10, x: 0, y: 5)
                }

                AppPromptTextEditor(
                    text: $store.prompt,
                    placeholder: "Example: Create a signup form with two fields and an orange continue button.",
                    isDisabled: store.isGenerating
                )

                exampleChips

                if let errorMessage = store.generationErrorMessage {
                    GenerationErrorBanner(message: errorMessage)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    private var bottomGenerateBar: some View {
        VStack {
            Spacer()

            GeneratingButton(
                title: store.generationPhase.buttonTitle,
                isGenerating: store.isGenerating,
                cancelAction: {
                    store.send(.cancelGenerationTapped)
                }
            ) {
                store.send(.generateTapped)
            }
            .padding(.horizontal, AppTheme.contentPadding)
            .padding(.top, 18)
            .padding(.bottom, 12)
            .background {
                LinearGradient(
                    colors: [
                        Color(hex: "#080B10").opacity(0.0),
                        Color(hex: "#080B10").opacity(0.82),
                        Color(hex: "#080B10")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var exampleChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(store.examples, id: \.self) { example in
                    AppChip(
                        title: example,
                        isSelected: store.selectedExample == example,
                        isDisabled: store.isGenerating
                    ) {
                        store.send(.exampleSelected(example))
                    }
                }
            }
        }
    }

    private var mainBackground: some View {
        ZStack {
            Color(hex: "#080B10")

            LinearGradient(
                colors: [
                    Color.white.opacity(0.035),
                    Color.clear,
                    Color.black.opacity(0.28)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }

    private func pipelineRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .default))
                .foregroundStyle(AppTheme.mutedText)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .default))
                .foregroundStyle(.white.opacity(0.90))
                .lineLimit(1)
        }
        .padding(.vertical, 11)
    }
}

private extension LLMProvider {
    var pipelineValue: String {
        switch self {
        case .localOllama:
            return "Local"
        case .openRouter:
            return "OpenRouter"
        case .openAI:
            return "OpenAI"
        case .gemini:
            return "Gemini"
        case .customEndpoint:
            return "Custom"
        }
    }
}

struct DynamicUIView_Previews: PreviewProvider {
    static var previews: some View {
        DynamicUIView(
            store: Store(initialState: DynamicUIFeature.State()) {
                DynamicUIFeature()
            }
        )
    }
}
