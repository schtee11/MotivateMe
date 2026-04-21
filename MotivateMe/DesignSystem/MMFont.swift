//
//  MMFont.swift
//  MotivateMe
//
//  Type scale ported from tokens.jsx. Uses SF Pro Rounded for display
//  weight, the system text font for body, monospaced for counters,
//  and serif italic for the gentle quote moments.
//

import SwiftUI

enum MMFont {
    // Apple-style scale, all rounded for display weight
    static let largeTitle = Font.system(size: 34, weight: .bold,     design: .rounded)
    static let title1     = Font.system(size: 28, weight: .bold,     design: .rounded)
    static let title2     = Font.system(size: 22, weight: .bold,     design: .rounded)
    static let title3     = Font.system(size: 20, weight: .semibold, design: .rounded)

    // Body/UI text — default font (system)
    static let headline   = Font.system(size: 17, weight: .semibold)
    static let body       = Font.system(size: 17, weight: .regular)
    static let callout    = Font.system(size: 16, weight: .regular)
    static let subhead    = Font.system(size: 15, weight: .regular)
    static let footnote   = Font.system(size: 13, weight: .regular)
    static let caption1   = Font.system(size: 12, weight: .regular)
    static let caption2   = Font.system(size: 11, weight: .medium)

    // Specials
    static let encourage  = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let streakHero = Font.system(size: 72, weight: .bold,     design: .rounded)
    static let counter    = Font.system(size: 15, weight: .medium,   design: .monospaced)

    /// Italic serif used for the gentle reflection / quote moments.
    static let quote      = Font.system(size: 16, weight: .medium, design: .serif).italic()
    static let quoteLarge = Font.system(size: 19, weight: .medium, design: .serif).italic()
}

// MARK: - Convenience modifier

extension View {
    func mmFont(_ font: Font, color: Color = MMColor.textPrimary) -> some View {
        self.font(font).foregroundStyle(color)
    }
}
