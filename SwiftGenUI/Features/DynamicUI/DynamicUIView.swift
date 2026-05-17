//
//  DynamicUIView.swift
//  SwiftGenUI
//
//  SwiftUI screen placeholder for the dynamic UI generator.
//

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

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: AppTheme.cardSpacing) {
                            header
                            promptComposer
                        }
                        .padding(.horizontal, AppTheme.contentPadding)
                        .padding(.bottom, 28)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $store.isPreviewPresented) {
                GeneratedPreviewView(store: store)
            }
        }
    }

    private var titleBar: some View {
        HStack(alignment: .center) {
            Text("SwiftGenUI")
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Spacer(minLength: 16)

            AppStatusBadge(title: "Local Qwen")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Turn natural language into safe native SwiftUI screens.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.mutedText)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                Label("Prompt", systemImage: "text.badge.sparkles")
                Label("Validate", systemImage: "checkmark.shield")
                Label("Render", systemImage: "iphone")
            }
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(AppTheme.cream.opacity(0.82))
        }
    }

    private var promptComposer: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionTitle(title: "What do you want to build?", systemImage: "wand.and.stars")

                AppPromptTextEditor(
                    text: $store.prompt,
                    placeholder: "Example: Create a signup form with two fields and an orange continue button."
                )

                exampleChips

                GeneratingButton(
                    title: store.isGenerating ? "Generating native UI..." : "Generate Native UI",
                    isGenerating: store.isGenerating
                ) {
                    store.send(.generateTapped)
                }
                .disabled(store.isGenerating)
            }
        }
    }

    private var exampleChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(store.examples, id: \.self) { example in
                    AppChip(title: example, isSelected: store.selectedExample == example) {
                        store.send(.exampleSelected(example))
                    }
                }
            }
        }
    }
}

private struct GeneratingButton: View {
    let title: String
    let isGenerating: Bool
    let action: () -> Void

    @State private var progress: CGFloat = 0

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(AppTheme.amberSoft.opacity(0.9))

                GeometryReader { proxy in
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.amberSoft, AppTheme.amber, AppTheme.cream],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * (isGenerating ? progress : 1))
                }
                .clipShape(RoundedRectangle(cornerRadius: 18))

                HStack {
                    Image(systemName: isGenerating ? "hourglass" : "sparkles")
                    Text(title)
                    Spacer()
                    Image(systemName: isGenerating ? "sparkles" : "arrow.right")
                }
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ink)
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }
            .frame(minHeight: 56)
        }
        .buttonStyle(.plain)
        .onAppear {
            updateProgress()
        }
        .onChange(of: isGenerating) { _, _ in
            updateProgress()
        }
    }

    private func updateProgress() {
        guard isGenerating else {
            withAnimation(.easeOut(duration: 0.18)) {
                progress = 1
            }
            return
        }

        progress = 0

        withAnimation(.easeInOut(duration: 1.15)) {
            progress = 1
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
