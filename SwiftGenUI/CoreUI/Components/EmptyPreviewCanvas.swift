
import SwiftUI

struct EmptyPreviewCanvas: View {
    let minHeight: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34)
                .fill(AppTheme.creamSoft)
                .shadow(color: .black.opacity(0.24), radius: 18, x: 0, y: 14)

            VStack(spacing: 12) {
                Image(systemName: "iphone.gen3")
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(AppTheme.amber)

                Text("Your generated SwiftUI screen will appear here.")
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundStyle(AppTheme.ink)
                    .multilineTextAlignment(.center)

                Text("Start with a precise layout prompt. Beauty comes after the renderer can obey.")
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundStyle(AppTheme.ink.opacity(0.58))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 18)
            }
            .padding(26)
        }
        .frame(minHeight: minHeight)
    }
}
