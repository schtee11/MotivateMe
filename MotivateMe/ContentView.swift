//
//  ContentView.swift
//  MotivateMe
//
//  Placeholder root view. Will be replaced by the onboarding-or-today
//  router once those flows are built.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("MotivateMe")
                    .font(.largeTitle).bold()

                Text(profiles.isEmpty ? "No profile yet" : "Profile loaded")
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
