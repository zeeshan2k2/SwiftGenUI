
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
            .background(.white.opacity(opacity), in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(.white.opacity(strokeOpacity), lineWidth: 1)
            }
    }
}
