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
    // stored; profiles from intermediate builds may hold a partial one.
    // Generate from splitStyle + daysPerWeek when empty, then normalize so
    // the 7-entry invariant holds before any consumer (streak, today) runs.
    private func ensureSchedule() {
        guard let profile = profiles.first else { return }
        var dirty = false
        if profile.weeklySchedule.isEmpty {
            profile.weeklySchedule = ScheduleGenerator.defaultSchedule(
                splitStyle: profile.splitStyle,
                daysPerWeek: profile.daysPerWeek
            )
            dirty = true
        }
        dirty = profile.normalizeWeeklySchedule() || dirty
        guard dirty else { return }
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
