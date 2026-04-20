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

    enum Range: String, CaseIterable, Identifiable {
        case week, month, quarter
        var id: String { rawValue }
        var title: String {
            switch self {
            case .week:    return "Week"
            case .month:   return "Month"
            case .quarter: return "90 days"
            }
        }
        var days: Int {
            switch self {
            case .week:    return 7
            case .month:   return 30
            case .quarter: return 90
            }
        }
        var eyebrow: String {
            switch self {
            case .week:    return "Last 7 days"
            case .month:   return "Last 30 days"
            case .quarter: return "Last 90 days"
            }
        }
    }

    /// Total completed-set count across `sessions` whose date falls within
    /// the last `days` calendar days. Excludes rest-day logs.
    static func totalSets(
        _ sessions: [Session],
        inLast days: Int,
        today: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        let startOfToday = calendar.startOfDay(for: today)
        guard let earliest = calendar.date(byAdding: .day, value: -(days - 1), to: startOfToday) else {
            return 0
        }
        return sessions.filter { session in
            session.status != .restDayLogged && session.date >= earliest
        }.reduce(0) { acc, session in
            acc + (session.sessionExercises ?? []).reduce(0) { $0 + $1.sets.filter(\.completed).count }
        }
    }

    /// Average readiness across the last `days` of check-ins. Returns nil
    /// if there are no check-ins with a readiness score in the window.
    static func averageReadiness(
        _ checkins: [DailyCheckin],
        inLast days: Int,
        today: Date = Date(),
        calendar: Calendar = .current
    ) -> Double? {
        let startOfToday = calendar.startOfDay(for: today)
        guard let earliest = calendar.date(byAdding: .day, value: -(days - 1), to: startOfToday) else {
            return nil
        }
        let scores = checkins.compactMap { c -> Int? in
            guard c.date >= earliest, let r = c.readinessScore else { return nil }
            return r
        }
        guard !scores.isEmpty else { return nil }
        return Double(scores.reduce(0, +)) / Double(scores.count)
    }

    /// Volume per week (last `weeks` weeks). Each value is the count of
    /// completed sets in that calendar week. Used by the trend line chart.
    static func weeklyVolumes(
        _ sessions: [Session],
        weeks: Int = 12,
        today: Date = Date(),
        calendar: Calendar = .current
    ) -> [Int] {
        var values: [Int] = []
        for offset in stride(from: weeks - 1, through: 0, by: -1) {
            guard let weekDate = calendar.date(byAdding: .weekOfYear, value: -offset, to: today),
                  let interval = calendar.dateInterval(of: .weekOfYear, for: weekDate) else {
                values.append(0); continue
            }
            let setCount = sessions
                .filter { $0.status != .restDayLogged && interval.contains($0.date) }
                .reduce(0) { $0 + ($1.sessionExercises ?? []).reduce(0) { $0 + $1.sets.filter(\.completed).count } }
            values.append(setCount)
        }
        return values
    }

    /// Percent change between the latest week and the prior one. Returns
    /// nil if there isn't enough data for a clean comparison.
    static func volumeTrendPercent(_ weeklyVolumes: [Int]) -> Int? {
        guard weeklyVolumes.count >= 2 else { return nil }
        let recent = weeklyVolumes.last ?? 0
        let prior = weeklyVolumes[weeklyVolumes.count - 2]
        guard prior > 0 else { return recent > 0 ? 100 : nil }
        let pct = Double(recent - prior) / Double(prior) * 100
        return Int(pct.rounded())
    }

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
