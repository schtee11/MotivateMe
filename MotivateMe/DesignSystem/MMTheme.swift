//
//  MMTheme.swift
//  MotivateMe
//
//  Applies app-wide visual defaults: warm background under tab bars,
//  peach accent on UIKit-backed elements (segmented control, slider,
//  switch, navigation bars). Call .applyMorningLightTheme() once at
//  app start.
//

import SwiftUI
import UIKit

extension View {
    /// Sets accent + background color for the whole app.
    func morningLightThemed() -> some View {
        self
            .tint(MMColor.primary)
            .background(MMColor.bg.ignoresSafeArea())
    }
}

/// Returns nil when the user has Reduce Motion enabled (either in our
/// Settings, or via the system accessibility setting mirrored by SwiftUI).
/// Pass into `.animation(_:value:)` and `withAnimation(_:)` to keep
/// transitions honest.
enum MMMotion {
    static var spring: Animation? {
        UserDefaults.standard.bool(forKey: "mm.reduceMotion")
            ? nil
            : .spring(response: 0.35, dampingFraction: 0.85)
    }

    static func spring(response: Double, damping: Double) -> Animation? {
        UserDefaults.standard.bool(forKey: "mm.reduceMotion")
            ? nil
            : .spring(response: response, dampingFraction: damping)
    }
}

enum MorningLightTheme {
    static func install() {
        let bg     = UIColor(MMColor.bg)
        let card   = UIColor(MMColor.surfaceCard)
        let primary = UIColor(MMColor.primary)
        let textPrimary = UIColor(MMColor.textPrimary)
        let textSecondary = UIColor(MMColor.textSecondary)

        // Tab bar — warm, not chrome gray
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithDefaultBackground()
        tabAppearance.backgroundColor = bg.withAlphaComponent(0.92)
        tabAppearance.shadowColor = UIColor(MMColor.separator)

        for state in [tabAppearance.stackedLayoutAppearance,
                      tabAppearance.inlineLayoutAppearance,
                      tabAppearance.compactInlineLayoutAppearance] {
            state.normal.iconColor = textSecondary
            state.normal.titleTextAttributes = [
                .foregroundColor: textSecondary,
                .font: UIFont.rounded(ofSize: 10, weight: .semibold),
            ]
            state.selected.iconColor = primary
            state.selected.titleTextAttributes = [
                .foregroundColor: primary,
                .font: UIFont.rounded(ofSize: 10, weight: .bold),
            ]
        }

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        // Navigation bar — flat, large titles in rounded
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.backgroundColor = bg
        navAppearance.shadowColor = .clear
        navAppearance.titleTextAttributes = [
            .foregroundColor: textPrimary,
            .font: UIFont.rounded(ofSize: 17, weight: .semibold),
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: textPrimary,
            .font: UIFont.rounded(ofSize: 34, weight: .bold),
        ]

        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = primary

        // Form / list backgrounds — let the warm bg show through
        UITableView.appearance().backgroundColor = .clear
        UICollectionView.appearance().backgroundColor = .clear

        // Switches use sage green (calm "on")
        UISwitch.appearance().onTintColor = UIColor(MMColor.success)

        // Sliders / segmented use peach
        UISlider.appearance().minimumTrackTintColor = primary
        UISegmentedControl.appearance().selectedSegmentTintColor = card
    }
}

private extension UIFont {
    static func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        guard let descriptor = base.fontDescriptor.withDesign(.rounded) else { return base }
        return UIFont(descriptor: descriptor, size: size)
    }
}
