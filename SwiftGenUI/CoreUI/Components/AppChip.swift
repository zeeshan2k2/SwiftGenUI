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
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(foregroundColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(backgroundColor, in: Capsule())
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

        return isSelected ? AppTheme.ink : AppTheme.cream
    }

    private var backgroundColor: Color {
        if isDisabled {
            return .white.opacity(0.05)
        }

        return isSelected ? AppTheme.cream : .white.opacity(0.08)
    }
}
