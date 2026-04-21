//
//  MainTabView.swift
//  MotivateMe
//
//  Top-level tab shell shown after onboarding. Per the Morning Light
//  design, the four tabs are Today / Journal / Progress / History.
//  Settings is reached from the avatar pill on Today, not the tab bar.
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

            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.closed.fill")
                }

            ProgressTabView(profile: profile)
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
        }
        .tint(MMColor.primary)
    }
}
