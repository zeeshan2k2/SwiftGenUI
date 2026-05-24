//
//  AppPrimaryButton.swift
//  SwiftGenUI
//
//  Primary call-to-action button.
//

import SwiftUI

struct AppPrimaryButton: View {
    let title: String
    let leadingSystemImage: String
    let trailingSystemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: leadingSystemImage)
                Text(title)
                Spacer()
                Image(systemName: trailingSystemImage)
            }
            .font(.system(size: 16, weight: .semibold, design: .default))
            .foregroundStyle(AppTheme.ink)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [AppTheme.amberSoft, AppTheme.amber],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 18)
            )
        }
        .buttonStyle(.plain)
    }
}
