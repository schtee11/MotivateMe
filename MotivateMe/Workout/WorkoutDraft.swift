//
//  WorkoutDraft.swift
//  MotivateMe
//
//  In-memory state for an in-progress workout. Created from a
//  WorkoutTemplate, mutated as the user logs sets, persisted to SwiftData
//  only when they tap Finish. Cancel-then-dismiss throws it away.
//
//  Only the top-level class is @Observable; nested drafts are value-type
//  structs so we can bind through array indices (SwiftUI tracks changes
//  via the Observable's keypath observers).
//

import Foundation
import SwiftData

@Observable
@MainActor
final class WorkoutDraft {
    let template: WorkoutTemplate
    let startedAt: Date = Date()
    var exerciseDrafts: [ExerciseDraft]

    init(template: WorkoutTemplate, previousSession: Session? = nil) {
        self.template = template
        self.exerciseDrafts = template.exerciseSlots
            .sorted(by: { $0.order < $1.order })
            .map(ExerciseDraft.init)
        if let previousSession {
            applyPreviousWeights(from: previousSession)
        }
    }

    // Seed weight fields from the user's last session of this template.
    // Matches by exerciseId + setNumber. Skips sets that logged no weight.
    private func applyPreviousWeights(from session: Session) {
        let previousByExercise: [UUID: [SetRecord]] = Dictionary(
            grouping: session.sessionExercises ?? [],
            by: { $0.exerciseId }
        ).mapValues { $0.flatMap(\.sets) }

        for exerciseIndex in exerciseDrafts.indices {
            let exerciseId = exerciseDrafts[exerciseIndex].slot.fallbackExerciseId
            guard let previousSets = previousByExercise[exerciseId] else { continue }

            for setIndex in exerciseDrafts[exerciseIndex].sets.indices {
                let setNumber = exerciseDrafts[exerciseIndex].sets[setIndex].setNumber
                guard let match = previousSets.first(where: { $0.setNumber == setNumber }),
                      let weight = match.weight, weight > 0
                else { continue }
                exerciseDrafts[exerciseIndex].sets[setIndex].weight = weight
                exerciseDrafts[exerciseIndex].sets[setIndex].previousWeight = weight
            }
        }
    }

    // Workflow status derived from what the user actually completed.
    // Nothing done → skipped; some done → partial; everything done → completed.
    private var computedStatus: SessionStatus {
        let allSets = exerciseDrafts.flatMap(\.sets)
        guard !allSets.isEmpty else { return .skipped }
        let completed = allSets.filter(\.completed).count
        if completed == 0 { return .skipped }
        if completed == allSets.count { return .completed }
        return .partial
    }

    func save(to context: ModelContext, effort: EffortLevel? = nil, notes: String? = nil) throws {
        let session = Session()
        session.workoutTemplateId = template.id
        session.date = startedAt
        session.completedAt = Date()
        session.durationSeconds = Int(Date().timeIntervalSince(startedAt))
        session.status = computedStatus
        session.effortRating = effort?.rating
        session.notes = notes

        // Snapshot today's check-in (if any) onto the session so historical
        // views can show "you felt a 6 that day" without joining against
        // DailyCheckin later.
        if let checkin = try? DailyCheckin.upsert(for: startedAt, in: context),
           let score = checkin.readinessScore {
            session.readinessScoreSnapshot = score
            session.readinessSource = checkin.readinessSource
        }

        session.sessionExercises = exerciseDrafts.enumerated().map { index, draft in
            let sessionExercise = SessionExercise()
            sessionExercise.exerciseId = draft.currentExerciseId
            sessionExercise.order = index
            sessionExercise.sets = draft.sets.map(\.asRecord)
            sessionExercise.skipped = draft.skipped
            sessionExercise.effortFeedback = draft.effort?.rawValue
            return sessionExercise
        }

        // PR detection runs before insert so the prior set excludes this
        // session by construction. Result is stored on the session and
        // surfaced as badges in History and on the Progress tab.
        let priorSessions = (try? context.fetch(FetchDescriptor<Session>())) ?? []
        session.prExerciseIds = Array(PRDetector.newPRs(in: session, against: priorSessions))

        context.insert(session)

        // Link the session into the DailyCheckin for today for fast reverse lookup.
        if let checkin = try? DailyCheckin.upsert(for: startedAt, in: context) {
            checkin.sessionId = session.id
            checkin.status = computedStatus
        }

        try context.save()
    }
}

struct ExerciseDraft: Identifiable {
    var id: UUID = UUID()
    let slot: ExerciseSlot
    // Defaults to slot.fallbackExerciseId; overridden when the user swaps
    // in an alternate mid-workout.
    var currentExerciseId: UUID
    var sets: [SetDraft]
    var skipped: Bool = false
    // Per-exercise effort bucket captured after the user logs at least one set.
    // Stored as EffortLevel.rawValue into SessionExercise.effortFeedback.
    var effort: EffortLevel?

    init(slot: ExerciseSlot) {
        self.slot = slot
        self.currentExerciseId = slot.fallbackExerciseId
        self.sets = (1...max(1, slot.sets)).map { n in SetDraft(setNumber: n, slot: slot) }
    }

    var exercise: Exercise? {
        LibraryStore.shared.exercises[currentExerciseId]
    }

    var targetDescription: String {
        let unit = slot.targetType == .reps ? "reps" : "sec"
        let range = slot.targetRangeMin == slot.targetRangeMax
            ? "\(slot.targetRangeMin)"
            : "\(slot.targetRangeMin)–\(slot.targetRangeMax)"
        return "\(slot.sets) × \(range) \(unit)"
    }

    var hasAnyCompletedSet: Bool {
        sets.contains(where: \.completed)
    }

    mutating func addSet() {
        let nextNumber = (sets.map(\.setNumber).max() ?? 0) + 1
        sets.append(SetDraft(setNumber: nextNumber, slot: slot))
    }

    mutating func removeSet(id: UUID) {
        sets.removeAll { $0.id == id }
    }
}

struct SetDraft: Identifiable {
    var id: UUID = UUID()
    var setNumber: Int
    var reps: Int?
    var durationSeconds: Int?
    var weight: Double?
    // Snapshot of the weight carried over from the previous session, if any.
    // Used only for the "last: N" hint under the weight field — never saved.
    var previousWeight: Double?
    var completed: Bool = false

    init(setNumber: Int, slot: ExerciseSlot) {
        self.setNumber = setNumber
        // Prefill the counted value with the top of the target range — the
        // most common case is "shoot for the top of the range." Users can
        // adjust down if they fall short.
        switch slot.targetType {
        case .reps:    self.reps = slot.targetRangeMax
        case .seconds: self.durationSeconds = slot.targetRangeMax
        }
    }

    var asRecord: SetRecord {
        SetRecord(
            setNumber: setNumber,
            reps: reps,
            durationSeconds: durationSeconds,
            weight: weight,
            completed: completed
        )
    }
}
