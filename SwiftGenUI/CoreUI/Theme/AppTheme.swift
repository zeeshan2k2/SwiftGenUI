
import SwiftUI

enum AppTheme {
    static let cornerRadius: CGFloat = 24
    static let contentPadding: CGFloat = 20
    static let cardSpacing: CGFloat = 16

    static let ink = Color(hex: "#0D111A")
    static let inkSoft = Color(hex: "#1A212E")
    static let cream = Color(hex: "#FAF0DB")
    static let creamSoft = Color(hex: "#FFF7E8")
    static let amber = Color(hex: "#FF8533")
    static let amberSoft = Color(hex: "#FFB864")
    static let sage = Color(hex: "#A3C7A8")
    static let mutedText = Color.white.opacity(0.66)

    static let workspaceGradient = LinearGradient(
        colors: [
            Color(hex: "#0A0D14"),
            Color(hex: "#171C29"),
            Color(hex: "#211A12")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
