//
//  MMShadow.swift
//  MotivateMe
//
//  Warm amber-tinted elevation. Light mode uses the rgba(70,45,25)
//  shadows from tokens.jsx; dark mode falls back to neutral black.
//

import SwiftUI

enum MMShadow {
    case xs, sm, md, lg, xl, glow
}

extension View {
    func mmShadow(_ level: MMShadow) -> some View {
        self.modifier(MMShadowModifier(level: level))
    }
}

private struct MMShadowModifier: ViewModifier {
    let level: MMShadow
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        switch level {
        case .xs:
            content.shadow(color: warm(0.06), radius: 1, x: 0, y: 1)
        case .sm:
            content
                .shadow(color: warm(0.06), radius: 3, x: 0, y: 2)
                .shadow(color: warm(0.04), radius: 1, x: 0, y: 1)
        case .md:
            content
                .shadow(color: warm(0.08), radius: 8, x: 0, y: 6)
                .shadow(color: warm(0.05), radius: 3, x: 0, y: 2)
        case .lg:
            content
                .shadow(color: warm(0.10), radius: 18, x: 0, y: 14)
                .shadow(color: warm(0.06), radius: 6, x: 0, y: 4)
        case .xl:
            content
                .shadow(color: warm(0.13), radius: 30, x: 0, y: 28)
                .shadow(color: warm(0.07), radius: 10, x: 0, y: 8)
        case .glow:
            content
                .shadow(color: glowTint(0.55), radius: 0, x: 0, y: 0)
                .shadow(color: warm(0.25), radius: 12, x: 0, y: 8)
        }
    }

    private func warm(_ alpha: Double) -> Color {
        scheme == .dark
            ? Color.black.opacity(alpha * 4)
            : Color(.sRGB, red: 70 / 255, green: 45 / 255, blue: 25 / 255, opacity: alpha)
    }

    private func glowTint(_ alpha: Double) -> Color {
        scheme == .dark
            ? Color(.sRGB, red: 0.40, green: 0.22, blue: 0.10, opacity: alpha * 0.5)
            : Color(.sRGB, red: 0.96, green: 0.78, blue: 0.55, opacity: alpha)
    }
}
