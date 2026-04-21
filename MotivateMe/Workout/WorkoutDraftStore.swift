//
//  WorkoutDraftStore.swift
//  MotivateMe
//
//  Durable snapshot of an in-progress WorkoutDraft. Persisted to
//  UserDefaults so a user who backgrounds the app (and gets evicted, or
//  force-quits) can resume the workout when they next open the app.
//
//  Cleared on Finish and on Discard. The MVP only supports a single active
//  workout at a time, so a singleton key is enough.
//

import Foundation
import OSLog

struct WorkoutDraftSnapshot: Codable {
    var templateId: UUID
    var startedAt: Date
    var exerciseDrafts: [ExerciseDraft]
}

enum WorkoutDraftStore {
    private static let key = "MotivateMe.WorkoutDraftSnapshot.v1"
    private static let log = Logger(subsystem: "com.williamtrout.MotivateMe", category: "workout-draft")

    static func save(_ snapshot: WorkoutDraftSnapshot, defaults: UserDefaults = .standard) {
        do {
            let data = try JSONEncoder().encode(snapshot)
            defaults.set(data, forKey: key)
        } catch {
            log.error("failed to encode in-progress workout: \(error.localizedDescription, privacy: .public)")
        }
    }

    static func load(defaults: UserDefaults = .standard) -> WorkoutDraftSnapshot? {
        guard let data = defaults.data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode(WorkoutDraftSnapshot.self, from: data)
        } catch {
            log.error("stored workout snapshot is unreadable, discarding: \(error.localizedDescription, privacy: .public)")
            defaults.removeObject(forKey: key)
            return nil
        }
    }

    static func clear(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: key)
    }
}
