
import SwiftUI

struct AppStatusBadge: View {
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(AppTheme.sage)
                .frame(width: 8, height: 8)

            Text(title)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(AppTheme.cream)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(.white.opacity(0.08), in: Capsule())
        .overlay {
            Capsule()
                .stroke(.white.opacity(0.14), lineWidth: 1)
        }
    }
}
