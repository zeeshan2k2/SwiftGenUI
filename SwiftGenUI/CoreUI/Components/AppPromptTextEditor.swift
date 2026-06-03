
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
            .frame(minHeight: 112)
            .padding(14)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "#0A0E13").opacity(isDisabled ? 0.68 : 0.98),
                        Color(hex: "#0F151B").opacity(isDisabled ? 0.60 : 0.98)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 14)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.white.opacity(isDisabled ? 0.06 : 0.08), lineWidth: 1)
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
