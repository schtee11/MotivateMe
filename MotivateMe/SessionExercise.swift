//
//  SessionExercise.swift
//  MotivateMe
//
//  What the user actually did for a given exercise within a Session.
//  The `sets` field is an array of value-type SetRecord structs, encoded
//  as a Data blob via Codable — fine for storage, not queryable via #Predicate.
//

import Foundation
import SwiftData

@Model
final class SessionExercise {
    var id: UUID = UUID()

    // Inverse of Session.sessionExercises. Optional because SwiftData +
    // CloudKit require relationships to be optional.
    var session: Session?

    // ID reference into the bundled Exercise library.
    var exerciseId: UUID = UUID()

    var order: Int = 0
    var sets: [SetRecord] = []
    var skipped: Bool = false
    var effortFeedback: String?

    init() {}
}

struct SetRecord: Codable, Hashable {
    var setNumber: Int
    // For counted exercises. Nil on timed (hold) sets.
    var reps: Int?
    // For timed exercises. Nil on counted sets.
    var durationSeconds: Int?
    var weight: Double?
    var completed: Bool
}
