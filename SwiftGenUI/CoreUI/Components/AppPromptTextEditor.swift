
import SwiftUI

struct AppPromptTextEditor: View {
    @Binding var text: String
    let placeholder: String
    var isDisabled = false

    var body: some View {
        TextEditor(text: $text)
            .scrollContentBackground(.hidden)
            .font(.system(size: 16, weight: .regular, design: .default))
            .foregroundStyle(isDisabled ? .white.opacity(0.52) : .white)
            .frame(minHeight: 118)
            .padding(14)
            .background(
                LinearGradient(
                    colors: [
                        AppTheme.inkSoft.opacity(isDisabled ? 0.58 : 0.92),
                        Color(hex: "#2A211B").opacity(isDisabled ? 0.48 : 0.74)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 20)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppTheme.amberSoft.opacity(isDisabled ? 0.08 : 0.14), lineWidth: 1)
            }
            .overlay(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundStyle(.white.opacity(0.36))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 22)
                        .allowsHitTesting(false)
                }
            }
            .disabled(isDisabled)
            .animation(.easeInOut(duration: 0.18), value: isDisabled)
    }
}
