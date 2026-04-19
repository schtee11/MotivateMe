//
//  MotivateMeApp.swift
//  MotivateMe
//
//  Created by William Trout on 4/18/26.
//

import SwiftUI
import SwiftData

@main
struct MotivateMeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            Session.self,
            SessionExercise.self,
            BodyMeasurement.self,
            DailyCheckin.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        LibraryStore.shared.load()
        MorningLightTheme.install()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(MMColor.primary)
        }
        .modelContainer(sharedModelContainer)
    }
}
