//
//  ContentView.swift
//  MotivateMe
//
//  Root router. If no UserProfile exists the user sees onboarding; after
//  onboarding saves, the @Query updates and we route to the main TabView
//  (Today + History).
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var errorPresenter = ErrorPresenter()

    var body: some View {
        Group {
            if profiles.isEmpty {
                OnboardingView()
            } else {
                MainTabView(profile: profiles[0])
            }
        }
        .environment(errorPresenter)
        .errorAlert(presenter: errorPresenter)
        .task { ensureSchedule() }
    }

    // Profiles created before the schedule feature shipped have no schedule
    // stored. Regenerate from splitStyle + daysPerWeek the first time we
    // see such a profile. A no-op otherwise.
    private func ensureSchedule() {
        guard let profile = profiles.first, profile.weeklySchedule.isEmpty else { return }
        profile.weeklySchedule = ScheduleGenerator.defaultSchedule(
            splitStyle: profile.splitStyle,
            daysPerWeek: profile.daysPerWeek
        )
        do {
            try modelContext.save()
        } catch {
            errorPresenter.present(error, context: "Setting up your weekly schedule")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
