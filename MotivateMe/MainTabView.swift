//
//  MainTabView.swift
//  MotivateMe
//
//  Top-level tab shell shown after onboarding. Two tabs for now — Today
//  (the landing screen) and History (past sessions). Each tab owns its
//  own NavigationStack.
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

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
        }
    }
}
