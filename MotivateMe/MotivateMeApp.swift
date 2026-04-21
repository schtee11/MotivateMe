//
//  MotivateMeApp.swift
//  MotivateMe
//
//  Created by William Trout on 4/18/26.
//

import SwiftUI
import SwiftData
import OSLog

@main
struct MotivateMeApp: App {
    private static let storageLog = Logger(subsystem: "com.williamtrout.MotivateMe", category: "storage")

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            Session.self,
            SessionExercise.self,
            BodyMeasurement.self,
            DailyCheckin.self,
        ])
        let persistentConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [persistentConfig])
        } catch {
            // Persistent store failed to open — typically a schema-migration mismatch
            // or corruption. Fall back to an in-memory container so the app can still
            // launch; the user will see empty state but won't crash. The underlying
            // file is left untouched so we can investigate and recover it later.
            Self.storageLog.error("Persistent ModelContainer failed: \(error.localizedDescription, privacy: .public). Falling back to in-memory storage.")

            let inMemoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: schema, configurations: [inMemoryConfig])
            } catch {
                Self.storageLog.critical("In-memory ModelContainer also failed: \(error.localizedDescription, privacy: .public)")
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()

    init() {
        LibraryStore.shared.load()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
