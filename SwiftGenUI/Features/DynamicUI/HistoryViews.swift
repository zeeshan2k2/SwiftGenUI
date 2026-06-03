
import SwiftUI

struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#151D24"))
                    .frame(width: 70, height: 70)

                Circle()
                    .stroke(.white.opacity(0.08), lineWidth: 1)
                    .frame(width: 70, height: 70)

                Image(systemName: "rectangle.stack.badge.plus")
                    .font(.system(size: 28, weight: .semibold, design: .default))
                    .foregroundStyle(Color(hex: "#DCE4EA"))
            }

            VStack(spacing: 7) {
                Text("No views rendered yet")
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundStyle(.white)

                Text("Generate your first native screen and it will appear here for quick replay.")
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundStyle(AppTheme.mutedText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 22)
        .padding(.vertical, 28)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "#27323D").opacity(0.62),
                    Color(hex: "#121A20").opacity(0.96),
                    Color.white.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
    }
}

struct HistoryRow: View {
    let item: DynamicUIFeature.State.HistoryItem
    let action: () -> Void

    private let rowCornerRadius: CGFloat = 20

    var body: some View {
        Button(action: action) {
            rowContent
        }
        .buttonStyle(.plain)
    }

    private var rowContent: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 15, weight: .semibold, design: .default))
                .foregroundStyle(Color(hex: "#DCE4EA"))
                .frame(width: 36, height: 36)
                .background(Color(hex: "#202A33"), in: Circle())
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .default))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(item.prompt)
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundStyle(AppTheme.mutedText)
                    .lineLimit(2)
            }

            Spacer(minLength: 12)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold, design: .default))
                .foregroundStyle(.white.opacity(0.32))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(hex: "#10161C"), in: RoundedRectangle(cornerRadius: rowCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: rowCornerRadius)
                .stroke(.white.opacity(0.06), lineWidth: 1)
        }
    }

    private var title: String {
        firstText(in: item.component) ?? item.component.type.rawValue
    }

    private var iconName: String {
        switch item.component.type {
        case .vStack, .hStack, .zStack, .card, .scrollView, .section:
            return "rectangle.3.group"
        case .text:
            return "textformat"
        case .button:
            return "capsule"
        case .textField:
            return "character.cursor.ibeam"
        case .spacer:
            return "arrow.up.and.down"
        case .divider:
            return "minus"
        }
    }

    private func firstText(in component: UIComponent) -> String? {
        if let text = component.props?.text, !text.isEmpty {
            return text
        }

        for child in component.children ?? [] {
            if let text = firstText(in: child) {
                return text
            }
        }

        return nil
    }
}
