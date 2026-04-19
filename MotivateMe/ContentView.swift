//
//  ContentView.swift
//  MotivateMe
//
//  Root router. If no UserProfile exists the user sees onboarding; after
//  onboarding saves, the @Query updates and we route to the Today screen
//  (a placeholder for now).
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var profiles: [UserProfile]

    var body: some View {
        if profiles.isEmpty {
            OnboardingView()
        } else {
            TodayPlaceholderView(profile: profiles[0])
        }
    }
}

// Temporary landing view shown post-onboarding until the real Today
// screen is built. Kept in this file so the router is easy to scan.
private struct TodayPlaceholderView: View {
    let profile: UserProfile

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("MotivateMe")
                    .font(.largeTitle).bold()

                Text("Profile loaded")
                    .foregroundStyle(.secondary)

                Text("Goals: \(profile.goals.map(\.displayName).sorted().joined(separator: ", "))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Text("Experience: \(profile.experienceLevel.displayName)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Text("Schedule: \(profile.daysPerWeek)× / week, \(profile.splitStyle.displayName)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Text("Library: \(LibraryStore.shared.exercises.count) exercises, \(LibraryStore.shared.workoutTemplates.count) templates")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
