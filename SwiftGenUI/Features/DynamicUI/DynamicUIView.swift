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
                Label("Prompt", systemImage: "sparkles")
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
            }
        }
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
        AppSectionTitle(title: "History", systemImage: "clock.arrow.circlepath")
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
}

private struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#1B6B8F").opacity(0.28))
                    .frame(width: 78, height: 78)

                Circle()
                    .stroke(Color(hex: "#9DE8FF").opacity(0.24), lineWidth: 1)
                    .frame(width: 78, height: 78)

                Image(systemName: "rectangle.stack.badge.plus")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#D7F7FF"), Color(hex: "#78D9F6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 7) {
                Text("No views rendered yet")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text("Generate your first native screen and it will appear here for quick replay.")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.mutedText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 22)
        .padding(.vertical, 28)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "#9DE8FF").opacity(0.12),
                    Color(hex: "#1B6B8F").opacity(0.18),
                    Color.white.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color(hex: "#9DE8FF").opacity(0.16), lineWidth: 1)
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
                .foregroundStyle(Color(hex: "#9DE8FF"))
                .frame(width: 38, height: 38)
                .background(Color(hex: "#1B6B8F").opacity(0.24), in: RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: "#9DE8FF").opacity(0.16), lineWidth: 1)
                }

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
        case .vStack, .hStack, .zStack, .card, .scrollView, .section:
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
                .fill(Color.white.opacity(isGenerating ? 0.12 : 0.14))

            if isGenerating {
                LinearGradient(
                    colors: [
                        Color(hex: "#A7F3FF").opacity(0.78),
                        Color(hex: "#B8A7FF").opacity(0.74),
                        Color(hex: "#FFB7D5").opacity(0.70),
                        Color(hex: "#FFD88A").opacity(0.76)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }

            LinearGradient(
                colors: fillColors,
                startPoint: .leading,
                endPoint: .trailing
            )
            .mask(alignment: .leading) {
                if isGenerating {
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.0),
                            .init(color: .white.opacity(0.70), location: 0.14),
                            .init(color: .white, location: 0.34),
                            .init(color: .white, location: 0.76),
                            .init(color: .white.opacity(0.66), location: 0.90),
                            .init(color: .clear, location: 1.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .scaleEffect(x: progress, y: 1, anchor: .leading)
                } else {
                    RoundedRectangle(cornerRadius: 18)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))

            if isGenerating {
                GeometryReader { proxy in
                    let sweepWidth = max(proxy.size.width * 0.20, 64)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.0),
                                    Color.white.opacity(0.52),
                                    Color(hex: "#E4D9FF").opacity(0.42),
                                    Color.white.opacity(0.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: sweepWidth)
                        .frame(height: proxy.size.height * 1.35)
                        .offset(x: progress * (proxy.size.width + sweepWidth) - sweepWidth)
                        .offset(y: -proxy.size.height * 0.18)
                        .blur(radius: 10)
                        .opacity(0.92)
                }
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }

            LinearGradient(
                colors: [
                    Color.white.opacity(isGenerating ? 0.22 : 0.34),
                    Color.white.opacity(0.02),
                    Color.black.opacity(isGenerating ? 0.04 : 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
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
            .foregroundStyle(Color(hex: "#10131A"))
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(isGenerating ? 0.56 : 0.34), lineWidth: 1)
        }
        .shadow(color: Color(hex: "#A7F3FF").opacity(isGenerating ? 0.40 : 0.14), radius: isGenerating ? 30 : 16, x: -12, y: 8)
        .shadow(color: Color(hex: "#B8A7FF").opacity(isGenerating ? 0.36 : 0.16), radius: isGenerating ? 34 : 18, x: 10, y: 10)
        .shadow(color: Color(hex: "#FFB7D5").opacity(isGenerating ? 0.30 : 0.12), radius: isGenerating ? 28 : 14, x: 0, y: 12)
    }

    private var fillColors: [Color] {
        if isGenerating {
            return [
                Color(hex: "#A7F3FF"),
                Color(hex: "#E4D9FF"),
                Color(hex: "#FFC4DE"),
                Color(hex: "#FFE7A6")
            ]
        }

        return [
            Color(hex: "#A7F3FF"),
            Color(hex: "#B8A7FF"),
            Color(hex: "#FFB7D5"),
            Color(hex: "#FFD88A")
        ]
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
