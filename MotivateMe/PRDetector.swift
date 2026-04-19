//
//  PRDetector.swift
//  MotivateMe
//
//  Pure functions over [Session] for personal-record bookkeeping. No state
//  of its own — recomputes from the session log every time. Cheap because
//  the log is small (months, not years) and we only flatten completed sets.
//
//  A "PR" here is the heaviest completed weight ever logged for an
//  exercise. Untimed bodyweight exercises (no weight, just reps) compare
//  on max reps in a single set instead.
//

import Foundation

enum PRDetector {

    // Per-exercise best summary used by both new-PR detection and the
    // Progress tab's recent-PRs / most-improved cards.
    struct Best {
        let weight: Double?   // nil for unweighted exercises
        let reps: Int?        // top-set reps at the best weight, or absolute max for bodyweight
        let date: Date
        let sessionId: UUID
    }

    // Returns exerciseIds for which `session` set a new best, judged
    // against everything in `priorSessions` (which must NOT include
    // `session` itself).
    static func newPRs(in session: Session, against priorSessions: [Session]) -> Set<UUID> {
        let priorBests = bests(across: priorSessions)
        var prs: Set<UUID> = []

        for sessionExercise in session.sessionExercises ?? [] {
            guard !sessionExercise.skipped else { continue }
            guard let candidate = best(in: sessionExercise.sets, date: session.date, sessionId: session.id)
            else { continue }
            let prior = priorBests[sessionExercise.exerciseId]
            if isBetter(candidate, than: prior) {
                prs.insert(sessionExercise.exerciseId)
            }
        }
        return prs
    }

    // Per-exercise best across an arbitrary slice of sessions. Used by the
    // Progress tab for "recent PRs" and "most improved" cards.
    static func bests(across sessions: [Session]) -> [UUID: Best] {
        var best: [UUID: Best] = [:]
        for session in sessions {
            for sessionExercise in session.sessionExercises ?? [] {
                guard !sessionExercise.skipped else { continue }
                guard let candidate = self.best(
                    in: sessionExercise.sets,
                    date: session.date,
                    sessionId: session.id
                ) else { continue }
                let existing = best[sessionExercise.exerciseId]
                if isBetter(candidate, than: existing) {
                    best[sessionExercise.exerciseId] = candidate
                }
            }
        }
        return best
    }

    // MARK: - Helpers

    private static func best(in sets: [SetRecord], date: Date, sessionId: UUID) -> Best? {
        let completed = sets.filter(\.completed)
        guard !completed.isEmpty else { return nil }

        // Weighted: heaviest weight wins; ties broken by max reps at that weight.
        if let topWeight = completed.compactMap(\.weight).filter({ $0 > 0 }).max() {
            let repsAtTop = completed
                .filter { ($0.weight ?? 0) == topWeight }
                .compactMap(\.reps)
                .max()
            return Best(weight: topWeight, reps: repsAtTop, date: date, sessionId: sessionId)
        }

        // Bodyweight / timed: compare on max reps in a set.
        if let topReps = completed.compactMap(\.reps).max() {
            return Best(weight: nil, reps: topReps, date: date, sessionId: sessionId)
        }

        return nil
    }

    private static func isBetter(_ candidate: Best, than prior: Best?) -> Bool {
        guard let prior else { return true }
        if let cw = candidate.weight, let pw = prior.weight {
            if cw != pw { return cw > pw }
            return (candidate.reps ?? 0) > (prior.reps ?? 0)
        }
        // Bodyweight comparison
        return (candidate.reps ?? 0) > (prior.reps ?? 0)
    }
}
