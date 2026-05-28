//
//  AppChip.swift
//  SwiftGenUI
//
//  Selectable chip component.
//

import SwiftUI

struct AppChip: View {
    let title: String
    let isSelected: Bool
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .default))
                .foregroundStyle(foregroundColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background {
                    Capsule()
                        .fill(Color.white.opacity(isDisabled ? 0.05 : 0.08))

                    if isSelected && !isDisabled {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#E9EDF5"),
                                        Color(hex: "#BFC7D6")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.56 : 1)
        .animation(.easeInOut(duration: 0.18), value: isDisabled)
    }

    private var foregroundColor: Color {
        if isDisabled {
            return AppTheme.cream.opacity(0.62)
        }

        return isSelected ? Color(hex: "#111827") : AppTheme.cream
    }
}
