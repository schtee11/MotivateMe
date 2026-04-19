//
//  MainTabView.swift
//  MotivateMe
//
//  Top-level tab shell shown after onboarding: Today (landing),
//  Progress (charts and PRs), History (past sessions), Settings.
//  Each tab owns its own NavigationStack.
//
//  The Morning Light tab bar appearance (warm bg, peach selected tint,
//  rounded labels) is installed at app launch in MorningLightTheme.install().
//

import SwiftUI

struct MainTabView: View {
    @Bindable var profile: UserProfile

    var body: some View {
        TabView {
            TodayView(profile: profile)
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }

            ProgressTabView(profile: profile)
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }

            SettingsView(profile: profile)
                .tabItem {
                    Label("Settings", systemImage: "person.crop.circle.fill")
                }
        }
        .tint(MMColor.primary)
    }
}
