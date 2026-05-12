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
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(isSelected ? AppTheme.ink : AppTheme.cream)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isSelected ? AppTheme.cream : .white.opacity(0.08), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
