
import SwiftUI

struct AppCard<Content: View>: View {
    private let opacity: Double
    private let strokeOpacity: Double
    private let content: Content

    init(
        opacity: Double = 0.08,
        strokeOpacity: Double = 0.12,
        @ViewBuilder content: () -> Content
    ) {
        self.opacity = opacity
        self.strokeOpacity = strokeOpacity
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .background(Color(hex: "#111820").opacity(0.96), in: RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.white.opacity(strokeOpacity), lineWidth: 1)
            }
    }
}
