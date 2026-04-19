//
//  ProgressStats.swift
//  MotivateMe
//
//  Aggregations over [Session] used by ProgressView. All pure functions
//  operating on the in-memory query result. We don't precompute or cache —
//  session counts are small (months, not years) and SwiftUI re-evaluates
//  views cheaply.
//

import Foundation

enum ProgressStats {

    struct WeekBucket: Identifiable {
        var id: Date { weekStart }
        let weekStart: Date
        let count: Int
    }

    struct RecentPR: Identifiable {
        var id: UUID { sessionId }
        let exerciseId: UUID
        let exerciseName: String
        let weight: Double?
        let reps: Int?
        let date: Date
        let sessionId: UUID
    }

    // Sessions started within the current calendar month, excluding rest-day
    // logs. "I worked out N times" is the user-friendly framing.
    static func sessionsThisMonth(
        _ sessions: [Session],
        today: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        guard let monthInterval = calendar.dateInterval(of: .month, for: today) else { return 0 }
        return sessions.filter { session in
            guard session.status != .restDayLogged else { return false }
            return monthInterval.contains(session.date)
        }.count
    }

    // Last `weeks` calendar weeks (oldest first), each bucket is a count of
    // workout sessions. Drives the bar chart on the Progress tab.
    static func weeklyBuckets(
        _ sessions: [Session],
        weeks: Int = 6,
        today: Date = Date(),
        calendar: Calendar = .current
    ) -> [WeekBucket] {
        var buckets: [WeekBucket] = []
        for offset in stride(from: weeks - 1, through: 0, by: -1) {
            guard let weekDate = calendar.date(byAdding: .weekOfYear, value: -offset, to: today),
                  let interval = calendar.dateInterval(of: .weekOfYear, for: weekDate)
            else { continue }
            let count = sessions.filter { session in
                guard session.status != .restDayLogged else { return false }
                return interval.contains(session.date)
            }.count
            buckets.append(WeekBucket(weekStart: interval.start, count: count))
        }
        return buckets
    }

    // PRs across all sessions, newest first, capped at `limit`. Each
    // session contributes one entry per exercise it set a PR for.
    static func recentPRs(_ sessions: [Session], limit: Int = 5) -> [RecentPR] {
        var collected: [RecentPR] = []
        let sortedNewestFirst = sessions.sorted(by: { $0.date > $1.date })

        for session in sortedNewestFirst {
            for exerciseId in session.prExerciseIds {
                guard let sessionExercise = session.sessionExercises?.first(where: { $0.exerciseId == exerciseId })
                else { continue }
                let topWeight = sessionExercise.sets
                    .filter(\.completed)
                    .compactMap(\.weight)
                    .filter { $0 > 0 }
                    .max()
                let reps: Int? = {
                    if let weight = topWeight {
                        return sessionExercise.sets
                            .filter { $0.completed && ($0.weight ?? 0) == weight }
                            .compactMap(\.reps)
                            .max()
                    }
                    return sessionExercise.sets
                        .filter(\.completed)
                        .compactMap(\.reps)
                        .max()
                }()
                let name = LibraryStore.shared.exercise(id: exerciseId)?.name ?? "Exercise"
                collected.append(RecentPR(
                    exerciseId: exerciseId,
                    exerciseName: name,
                    weight: topWeight,
                    reps: reps,
                    date: session.date,
                    sessionId: session.id
                ))
                if collected.count >= limit { return collected }
            }
        }
        return collected
    }
}
