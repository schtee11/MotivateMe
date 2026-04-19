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

    // Exercise IDs (into LibraryStore) for which this session set a new
    // personal record. Computed at save time by PRDetector and surfaced
    // as badges in History and on the Progress tab.
    var prExerciseIds: [UUID] = []

    init() {}
}
