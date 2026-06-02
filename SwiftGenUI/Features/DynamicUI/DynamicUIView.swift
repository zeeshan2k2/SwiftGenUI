
import ComposableArchitecture
import SwiftUI

struct DynamicUIView: View {
    @Bindable var store: StoreOf<DynamicUIFeature>

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.workspaceGradient
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: AppTheme.cardSpacing) {
                    titleBar
                        .padding(.horizontal, AppTheme.contentPadding)
                        .padding(.top, 18)

                    contentList
                }
            }
            .navigationBarHidden(true)
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
        List {
            header
                .listRowStyle(top: 0, bottom: 8)

            promptComposer
                .listRowStyle()

            generationHistory
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }

    private var titleBar: some View {
        HStack(alignment: .center) {
            Text("SwiftGenUI")
                .font(.system(size: 36, weight: .semibold, design: .default))
                .foregroundStyle(.white)

            Spacer(minLength: 16)

            ModelProviderButton(
                title: store.providerButtonTitle,
                provider: store.selectedProvider
            ) {
                store.send(.modelButtonTapped)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Turn natural language into safe native SwiftUI screens.")
                .font(.system(size: 15, weight: .regular, design: .default))
                .foregroundStyle(AppTheme.mutedText)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                FeatureStepLabel(title: "Prompt", systemImage: "sparkles", accentColor: AppTheme.amberSoft)
                FeatureStepLabel(title: "Validate", systemImage: "checkmark.shield", accentColor: AppTheme.sage)
                FeatureStepLabel(title: "Render", systemImage: "iphone", accentColor: Color(hex: "#78D9F6"))
            }
        }
    }

    private var promptComposer: some View {
        AppCard(opacity: 0.10, strokeOpacity: 0.15) {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionTitle(title: "What do you want to build?", systemImage: "wand.and.stars")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.cream, AppTheme.amberSoft],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                AppPromptTextEditor(
                    text: $store.prompt,
                    placeholder: "Example: Create a signup form with two fields and an orange continue button.",
                    isDisabled: store.isGenerating
                )

                exampleChips

                GeneratingButton(
                    title: store.generationPhase.buttonTitle,
                    isGenerating: store.isGenerating,
                    cancelAction: {
                        store.send(.cancelGenerationTapped)
                    }
                ) {
                    store.send(.generateTapped)
                }

                if let errorMessage = store.generationErrorMessage {
                    GenerationErrorBanner(message: errorMessage)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .background(promptAccent)
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

    @ViewBuilder
    private var generationHistory: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(hex: "#78D9F6"))

            Text("History")
                .font(.system(size: 15, weight: .semibold, design: .default))
                .foregroundStyle(.white)
        }
        .listRowStyle(top: 8, bottom: 2)

        if store.generationHistory.isEmpty {
            EmptyHistoryView()
                .listRowStyle(top: 5, bottom: 5)
        } else {
            ForEach(store.generationHistory) { item in
                HistoryRow(item: item) {
                    store.send(.historySelected(item.id))
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        store.send(.historyDeleteTapped(item.id))
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .listRowStyle(top: 5, bottom: 5)
            }
        }
    }

    private var promptAccent: some View {
        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
            .fill(
                LinearGradient(
                    colors: [
                        AppTheme.amber.opacity(0.20),
                        Color(hex: "#FF5A7A").opacity(0.10),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .blur(radius: 10)
            .offset(y: 4)
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
