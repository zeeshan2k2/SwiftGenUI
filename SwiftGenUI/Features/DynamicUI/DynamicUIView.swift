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
        ZStack {
            AppTheme.workspaceGradient
                .ignoresSafeArea()

            GeometryReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppTheme.cardSpacing) {
                        header
                        promptComposer
                        previewCanvas(minHeight: max(260, proxy.size.height * 0.32))
                        schemaCard
                    }
                    .padding(.horizontal, AppTheme.contentPadding)
                    .padding(.top, 18)
                    .padding(.bottom, 28)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("SwiftGenUI")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Turn natural language into safe native SwiftUI screens.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.mutedText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 16)

                AppStatusBadge(title: "Local Qwen")
            }

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

                AppPrimaryButton(
                    title: store.isGenerating ? "Generating..." : "Generate Native UI",
                    leadingSystemImage: store.isGenerating ? "hourglass" : "sparkles",
                    trailingSystemImage: "arrow.right"
                ) {
                    store.send(.generateTapped)
                }
                .disabled(store.isGenerating)
                .opacity(store.isGenerating ? 0.72 : 1)
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

    private func previewCanvas(minHeight: CGFloat) -> some View {
        AppCard(opacity: 0.07, strokeOpacity: 0.12) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    AppSectionTitle(title: "Live native preview", systemImage: "rectangle.on.rectangle")
                    Spacer()
                    Text(store.generationStatus)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(AppTheme.sage)
                }

                if let component = store.generatedComponent {
                    DynamicRenderer(component: component)
                        .frame(maxWidth: .infinity, minHeight: minHeight)
                } else {
                    EmptyPreviewCanvas(minHeight: minHeight)
                }
            }
        }
    }

    private var schemaCard: some View {
        AppCard(opacity: 0.06, strokeOpacity: 0.10) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    AppSectionTitle(title: "Schema inspector", systemImage: "curlybraces")
                    Spacer()
                    Text(store.generatedSchema == nil ? "Empty" : "Ready")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.45))
                }

                Text(store.generatedSchema ?? "Generated JSON will be shown here after validation.")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(AppTheme.mutedText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 16))
            }
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
