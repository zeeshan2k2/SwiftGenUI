//
//  GenerationHistoryView.swift
//  SwiftGenUI
//
//  Dedicated archive for previously rendered native UI screens.
//

import ComposableArchitecture
import SwiftUI

struct GenerationHistoryView: View {
    @Bindable var store: StoreOf<DynamicUIFeature>

    var body: some View {
        ZStack {
            historyBackground

            VStack(alignment: .leading, spacing: AppTheme.cardSpacing) {
                headerCard
                    .padding(.horizontal, AppTheme.contentPadding)
                    .padding(.top, 8)

                historyContent
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
        .navigationDestination(isPresented: $store.isPreviewPresented) {
            GeneratedPreviewView(store: store)
        }
    }

    private var headerCard: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Generation Archive")
                    .font(.system(size: 12, weight: .semibold, design: .default))
                    .foregroundStyle(AppTheme.mutedText)

                Text("History")
                    .font(.system(size: 24, weight: .semibold, design: .default))
                    .foregroundStyle(.white)

                Text("Replay previously rendered native screens")
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .foregroundStyle(AppTheme.mutedText)
            }
            .layoutPriority(1)

            Spacer(minLength: 8)

            archiveStatusStack
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#121A20"), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(.white.opacity(0.055), lineWidth: 1)
        }
    }

    @ViewBuilder
    private var historyContent: some View {
        if store.generationHistory.isEmpty {
            VStack {
                Spacer(minLength: 12)
                EmptyHistoryView()
                    .padding(.horizontal, AppTheme.contentPadding)
                Spacer(minLength: 0)
            }
        } else {
            List {
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
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
    }

    private var historyBackground: some View {
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

    private var archiveStatusStack: some View {
        VStack(alignment: .trailing, spacing: 5) {
            Text("SwiftUI")
                .font(.system(size: 12, weight: .semibold, design: .default))
                .foregroundStyle(.white.opacity(0.90))

            Text("\(store.generationHistory.count) saved")
                .font(.system(size: 11, weight: .semibold, design: .default))
                .foregroundStyle(AppTheme.mutedText)
        }
    }
}

struct HistoryTopButton: View {
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundStyle(.white)
                    .frame(width: 54, height: 54)
                    .background(Color(hex: "#121A20"), in: RoundedRectangle(cornerRadius: 18))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(.white.opacity(0.09), lineWidth: 1)
                    }

                if count > 0 {
                    Text("\(min(count, 99))")
                        .font(.system(size: 9, weight: .bold, design: .default))
                        .foregroundStyle(Color(hex: "#0B1015"))
                        .frame(minWidth: 18, minHeight: 18)
                        .padding(.horizontal, count > 9 ? 4 : 0)
                        .background(Color(hex: "#F4F6F8"), in: Capsule())
                        .offset(x: 6, y: -6)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open generated UI history")
    }
}
