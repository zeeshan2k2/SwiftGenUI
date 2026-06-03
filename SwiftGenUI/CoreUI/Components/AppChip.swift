
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
                .padding(.vertical, 9)
                .background {
                    Capsule()
                        .fill(Color(hex: "#151D24").opacity(isDisabled ? 0.55 : 1))

                    if isSelected && !isDisabled {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#E7EAED"),
                                        Color(hex: "#C7CED4")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                .overlay {
                    Capsule()
                        .stroke(.white.opacity(isSelected ? 0.16 : 0.08), lineWidth: 1)
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

        return isSelected ? Color(hex: "#10161C") : AppTheme.cream
    }
}
