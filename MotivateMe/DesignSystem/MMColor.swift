//
//  MMColor.swift
//  MotivateMe
//
//  "Morning Light" palette ported from the design system's tokens.jsx.
//  oklch values were converted to sRGB hex once and frozen here so the
//  app does not need a runtime oklch implementation. Colors auto-resolve
//  light/dark via Color(light:dark:).
//

import SwiftUI
import UIKit

enum MMColor {
    // MARK: - Surfaces

    static let bg            = dynamic(light: 0xFBFAF8, dark: 0x241F1A)
    static let surface       = dynamic(light: 0xFFFFFF, dark: 0x2A2520)
    static let surfaceRaised = dynamic(light: 0xFFFFFF, dark: 0x2F2A24)
    static let surfaceCard   = dynamic(light: 0xFFFFFF, dark: 0x2F2A24)
    static let surfaceElevated = dynamic(light: 0xFFFFFF, dark: 0x383229)
    static let surfaceModal  = dynamic(light: 0xFFFFFF, dark: 0x43392E)
    static let surfaceInput  = dynamic(light: 0xF8F6F3, dark: 0x2F2A24)

    // MARK: - Text

    static let textPrimary   = dynamic(light: 0x3A332B, dark: 0xF1ECDF)
    static let textSecondary = dynamic(light: 0x7A7368, dark: 0x8E8270)
    static let textTertiary  = dynamic(light: 0x9C958B, dark: 0x6F6253)
    static let textOnColor   = Color.white

    // MARK: - Lines

    static let separator = Color(light: rgba(60, 45, 30, 0.08),
                                 dark: rgba(255, 255, 255, 0.08))
    static let separatorStrong = Color(light: rgba(60, 45, 30, 0.14),
                                       dark: rgba(255, 255, 255, 0.14))
    static let border = Color(light: rgba(60, 45, 30, 0.10),
                              dark: rgba(255, 255, 255, 0.10))

    // MARK: - Brand (peach primary, sage secondary)

    static let primary       = dynamic(light: 0xE89F80, dark: 0xE89F80)
    static let primaryHover  = dynamic(light: 0xD0876A, dark: 0xD0876A)
    static let primaryMuted  = dynamic(light: 0xF7E3D2, dark: 0x7A3C2E)
    static let primaryTint   = dynamic(light: 0xFCEFE5, dark: 0x3A2A1F)
    static let onPrimary     = Color.white

    static let secondary     = dynamic(light: 0x7F8C66, dark: 0x94A079)
    static let secondaryMuted = dynamic(light: 0xDEE3D5, dark: 0x3D4736)
    static let secondaryTint = dynamic(light: 0xEEF1E9, dark: 0x2A3025)

    // MARK: - Semantic (warm family)

    static let success     = dynamic(light: 0x7F8C66, dark: 0x94A079)
    static let successTint = dynamic(light: 0xEEF1E9, dark: 0x2A3025)
    static let warning     = dynamic(light: 0xC79338, dark: 0xD9A655)
    static let warningTint = dynamic(light: 0xFBEFD3, dark: 0x3A2D17)
    static let info        = dynamic(light: 0x7F95A8, dark: 0x9DB1C0)
    static let infoTint    = dynamic(light: 0xE6ECF1, dark: 0x223038)
    static let error       = dynamic(light: 0xB85B3F, dark: 0xCC6E51)
    static let errorTint   = dynamic(light: 0xF8E2DA, dark: 0x3A1F18)

    // MARK: - Heatmap & ring scales (peach 100..600)

    static let peachScale: [Color] = [
        dynamic(light: 0xFCEFE5, dark: 0x3A2A1F), // 100
        dynamic(light: 0xF4D2B4, dark: 0x5A3729),
        dynamic(light: 0xEEBB97, dark: 0x7A3C2E),
        dynamic(light: 0xEAAE89, dark: 0x9F4F39),
        dynamic(light: 0xE89F80, dark: 0xE89F80), // 500
        dynamic(light: 0xD0876A, dark: 0xEFB69A),
    ]

    // MARK: - Helpers

    private static func dynamic(light: Int, dark: Int) -> Color {
        Color(light: hex(light), dark: hex(dark))
    }

    private static func hex(_ value: Int) -> Color {
        Color(.sRGB,
              red:   Double((value >> 16) & 0xFF) / 255.0,
              green: Double((value >> 8)  & 0xFF) / 255.0,
              blue:  Double(value         & 0xFF) / 255.0,
              opacity: 1)
    }

    private static func rgba(_ r: Double, _ g: Double, _ b: Double, _ a: Double) -> Color {
        Color(.sRGB, red: r / 255, green: g / 255, blue: b / 255, opacity: a)
    }
}

// MARK: - Color(light:dark:)

extension Color {
    init(light: Color, dark: Color) {
        self = Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}
