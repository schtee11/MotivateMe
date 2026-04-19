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
final class WorkoutDraft {
    let template: WorkoutTemplate
    let startedAt: Date = Date()
    var exerciseDrafts: [ExerciseDraft]

    init(template: WorkoutTemplate) {
        self.template = template
        self.exerciseDrafts = template.exerciseSlots
            .sorted(by: { $0.order < $1.order })
            .map(ExerciseDraft.init)
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

    func save(to context: ModelContext) {
        let session = Session()
        session.workoutTemplateId = template.id
        session.date = startedAt
        session.completedAt = Date()
        session.durationSeconds = Int(Date().timeIntervalSince(startedAt))
        session.status = computedStatus

        session.sessionExercises = exerciseDrafts.enumerated().map { index, draft in
            let sessionExercise = SessionExercise()
            sessionExercise.exerciseId = draft.slot.fallbackExerciseId
            sessionExercise.order = index
            sessionExercise.sets = draft.sets.map(\.asRecord)
            sessionExercise.skipped = draft.skipped
            return sessionExercise
        }

        context.insert(session)
        do {
            try context.save()
        } catch {
            print("WorkoutDraft: failed to save session: \(error)")
        }
    }
}

struct ExerciseDraft: Identifiable {
    var id: UUID = UUID()
    let slot: ExerciseSlot
    var sets: [SetDraft]
    var skipped: Bool = false

    init(slot: ExerciseSlot) {
        self.slot = slot
        self.sets = (1...max(1, slot.sets)).map { n in SetDraft(setNumber: n, slot: slot) }
    }

    var exercise: Exercise? {
        LibraryStore.shared.exercises[slot.fallbackExerciseId]
    }

    var targetDescription: String {
        let unit = slot.targetType == .reps ? "reps" : "sec"
        let range = slot.targetRangeMin == slot.targetRangeMax
            ? "\(slot.targetRangeMin)"
            : "\(slot.targetRangeMin)–\(slot.targetRangeMax)"
        return "\(slot.sets) × \(range) \(unit)"
    }
}

struct SetDraft: Identifiable {
    var id: UUID = UUID()
    var setNumber: Int
    var reps: Int?
    var durationSeconds: Int?
    var weight: Double?
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
