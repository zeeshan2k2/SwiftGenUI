//
//  DynamicUIView.swift
//  SwiftGenUI
//
//  SwiftUI screen placeholder for the dynamic UI generator.
//

import SwiftUI

struct DynamicUIView: View {
    @State private var state = DynamicUIFeature.State()

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
                    text: $state.prompt,
                    placeholder: "Example: Create a signup form with two fields and an orange continue button."
                )

                exampleChips

                AppPrimaryButton(
                    title: "Generate Native UI",
                    leadingSystemImage: "sparkles",
                    trailingSystemImage: "arrow.right"
                ) {
                    state.generationStatus = state.prompt.isEmpty ? "Add a prompt first" : "Preview queued"
                }
            }
        }
    }

    private var exampleChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(state.examples, id: \.self) { example in
                    AppChip(title: example, isSelected: state.selectedExample == example) {
                        state.selectedExample = example
                        state.prompt = state.examplePrompts[example] ?? example
                        state.generationStatus = "Example loaded"
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
                    Text(state.generationStatus)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(AppTheme.sage)
                }

                EmptyPreviewCanvas(minHeight: minHeight)
            }
        }
    }

    private var schemaCard: some View {
        AppCard(opacity: 0.06, strokeOpacity: 0.10) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    AppSectionTitle(title: "Schema inspector", systemImage: "curlybraces")
                    Spacer()
                    Text("Empty")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.45))
                }

                Text("Generated JSON will be shown here after validation.")
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
        DynamicUIView()
    }
}
