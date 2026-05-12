//
//  AppPromptTextEditor.swift
//  SwiftGenUI
//
//  Prompt editor with placeholder support.
//

import SwiftUI

struct AppPromptTextEditor: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        TextEditor(text: $text)
            .scrollContentBackground(.hidden)
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundStyle(.white)
            .frame(minHeight: 118)
            .padding(14)
            .background(AppTheme.inkSoft.opacity(0.9), in: RoundedRectangle(cornerRadius: 20))
            .overlay(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.36))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 22)
                        .allowsHitTesting(false)
                }
            }
    }
}
