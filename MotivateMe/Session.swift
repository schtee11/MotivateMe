//
//  Session.swift
//  MotivateMe
//
//  One record per workout attempt (completed, partial, skipped, or rest-day-logged).
//  Owns its SessionExercise children via a cascade delete relationship.
//

import Foundation
import SwiftData

@Model
final class Session {
    var id: UUID = UUID()
    var date: Date = Date()
    var completedAt: Date?

    // ID reference (not a SwiftData relationship) — WorkoutTemplate lives in the
    // bundled library, not in SwiftData. Nullable because sessions can be ad-hoc.
    var workoutTemplateId: UUID?

    var status: SessionStatus = SessionStatus.upcoming

    @Relationship(deleteRule: .cascade, inverse: \SessionExercise.session)
    var sessionExercises: [SessionExercise]? = []

    var durationSeconds: Int?
    var effortRating: Int?
    var notes: String?

    var readinessScoreSnapshot: Int?
    var readinessSource: ReadinessSource = ReadinessSource.none

    init() {}
}
