//
//  DynamicUIHelpers.swift
//  SwiftGenUI
//
//  Small supporting views and modifiers for the dynamic UI screen.
//

import SwiftUI

struct FeatureStepLabel: View {
    let title: String
    let systemImage: String
    let accentColor: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .foregroundStyle(accentColor)
            Text(title)
                .foregroundStyle(AppTheme.cream.opacity(0.82))
        }
        .font(.system(size: 12, weight: .medium, design: .default))
    }
}

struct GenerationErrorBanner: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(hex: "#FFD38A"))
                .padding(.top, 1)

            Text(message)
                .font(.system(size: 13, weight: .medium, design: .default))
                .foregroundStyle(AppTheme.cream.opacity(0.90))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "#4A3321").opacity(0.72),
                    Color(hex: "#2A1E1A").opacity(0.72)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 16)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#FFD38A").opacity(0.18), lineWidth: 1)
        }
    }
}

extension View {
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
