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

                    contentList
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $store.isPreviewPresented) {
                GeneratedPreviewView(store: store)
            }
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
                    isGenerating: store.isGenerating,
                    cancelAction: {
                        store.send(.cancelGenerationTapped)
                    }
                ) {
                    store.send(.generateTapped)
                }
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

    @ViewBuilder
    private var generationHistory: some View {
        if !store.generationHistory.isEmpty {
            AppSectionTitle(title: "History", systemImage: "clock.arrow.circlepath")
                .listRowStyle(top: 8, bottom: 2)

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
}

private struct HistoryRow: View {
    let item: DynamicUIFeature.State.HistoryItem
    let action: () -> Void

    private let rowCornerRadius: CGFloat = 20

    var body: some View {
        Button(action: action) {
            rowContent
        }
        .buttonStyle(.plain)
    }

    private var rowContent: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.amber)
                .frame(width: 38, height: 38)
                .background(AppTheme.amber.opacity(0.14), in: RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(item.prompt)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.mutedText)
                    .lineLimit(2)
            }

            Spacer(minLength: 12)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.32))
        }
        .padding(14)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: rowCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: rowCornerRadius)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        }
    }

    private var title: String {
        firstText(in: item.component) ?? item.component.type.rawValue
    }

    private var iconName: String {
        switch item.component.type {
        case .vStack, .hStack, .zStack:
            return "rectangle.3.group"
        case .text:
            return "textformat"
        case .button:
            return "capsule"
        case .textField:
            return "character.cursor.ibeam"
        case .spacer:
            return "arrow.up.and.down"
        case .divider:
            return "minus"
        }
    }

    private func firstText(in component: UIComponent) -> String? {
        if let text = component.props?.text, !text.isEmpty {
            return text
        }

        for child in component.children ?? [] {
            if let text = firstText(in: child) {
                return text
            }
        }

        return nil
    }
}

private struct GeneratingButton: View {
    let title: String
    let isGenerating: Bool
    let cancelAction: () -> Void
    let action: () -> Void

    @State private var progress: CGFloat = 0
    @State private var loadingCycle = 0

    var body: some View {
        HStack(spacing: 10) {
            Button(action: action) {
                buttonContent
            }
            .buttonStyle(.plain)
            .disabled(isGenerating)

            if isGenerating {
                Button(action: cancelAction) {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#FF5A66"), Color(hex: "#B42335")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 18)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(.white.opacity(0.20), lineWidth: 1)
                        }
                        .shadow(color: Color(hex: "#B42335").opacity(0.32), radius: 16, x: 0, y: 10)
                }
                .buttonStyle(.plain)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.86).combined(with: .opacity).combined(with: .move(edge: .trailing)),
                    removal: .scale(scale: 0.86).combined(with: .opacity)
                ))
            }
        }
        .animation(.spring(response: 0.34, dampingFraction: 0.82), value: isGenerating)
        .onAppear {
            updateProgress()
        }
        .onChange(of: isGenerating) { _, _ in
            updateProgress()
        }
        .onChange(of: loadingCycle) { _, _ in
            continueLoadingIfNeeded()
        }
    }

    private var buttonContent: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.amberSoft.opacity(0.9))

            LinearGradient(
                colors: [AppTheme.amberSoft, AppTheme.amber, AppTheme.cream],
                startPoint: .leading,
                endPoint: .trailing
            )
            .scaleEffect(x: isGenerating ? progress : 1, y: 1, anchor: .leading)
            .clipShape(RoundedRectangle(cornerRadius: 18))

            HStack(spacing: 12) {
                Image(systemName: isGenerating ? "hourglass" : "sparkles")
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.84)
                Spacer()
                Image(systemName: isGenerating ? "sparkles" : "arrow.right")
            }
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(AppTheme.ink)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity, minHeight: 56)
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

        continueLoadingIfNeeded()
    }

    private func continueLoadingIfNeeded() {
        guard isGenerating else { return }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.15))
            guard isGenerating else { return }

            progress = 0

            withAnimation(.easeInOut(duration: 1.15)) {
                progress = 1
            }

            loadingCycle += 1
        }
    }
}

private extension View {
    func listRowStyle(top: CGFloat = 6, bottom: CGFloat = 6) -> some View {
        self
            .listRowInsets(EdgeInsets(
                top: top,
                leading: AppTheme.contentPadding,
                bottom: bottom,
                trailing: AppTheme.contentPadding
            ))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
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
