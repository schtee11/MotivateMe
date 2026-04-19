//
//  MainTabView.swift
//  MotivateMe
//
//  Top-level tab shell shown after onboarding: Today (landing),
//  Progress (charts and PRs), History (past sessions), Settings.
//  Each tab owns its own NavigationStack.
//

import SwiftUI

struct MainTabView: View {
    @Bindable var profile: UserProfile

    var body: some View {
        TabView {
            TodayView(profile: profile)
                .tabItem {
                    Label("Today", systemImage: "figure.run")
                }

            ProgressTabView(profile: profile)
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }

            SettingsView(profile: profile)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}
