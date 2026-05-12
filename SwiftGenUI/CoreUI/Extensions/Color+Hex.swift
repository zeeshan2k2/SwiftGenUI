//
//  Color+Hex.swift
//  SwiftGenUI
//
//  Hex color helpers for reusable SwiftUI color creation.
//

import SwiftUI

extension Color {
    init(hex: String, alpha: CGFloat = 1.0) {
        var normalized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if normalized.hasPrefix("#") {
            normalized.removeFirst()
        }

        if normalized.count == 3 {
            normalized = normalized.map { "\($0)\($0)" }.joined()
        }

        guard normalized.count == 6, let value = UInt32(normalized, radix: 16) else {
            self = Color(.sRGB, red: 0, green: 0, blue: 0, opacity: alpha)
            return
        }

        let red = Double((value & 0xFF0000) >> 16) / 255.0
        let green = Double((value & 0x00FF00) >> 8) / 255.0
        let blue = Double(value & 0x0000FF) / 255.0
        self = Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    init(hex: UInt, alpha: Double = 1.0) {
        self.init(hex: String(format: "%06X", hex), alpha: alpha)
    }
}
