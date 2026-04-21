//
//  StreakCalculator.swift
//  MotivateMe
//
//  Computes the current streak — the number of consecutive days, counted
//  back from today, where the user "satisfied" the day. A day is satisfied
//  if either:
//    • a Session exists for that calendar day (any status), or
//    • the profile's weekly schedule marks that weekday as a rest day.
//
//  The forgiveness window lets the user miss up to N scheduled workout days
//  without breaking the streak. Missed days are absorbed silently — they do
//  not extend the streak but do not break it either. Once the budget is
//  exhausted, the next miss breaks the walk.
//
//  Relies on the UserProfile.weeklySchedule invariant (7 entries, one per
//  weekday, enforced by UserProfile.normalizeWeeklySchedule()). A profile
//  with no scheduled workout days at all has no goal to streak against, so
//  we return 0 rather than rolling up rest days into an infinite streak.
//
//  Today counts only if already satisfied; otherwise the walk starts at
//  yesterday so an active day in progress doesn't count as breaking the
//  streak.
//

import Foundation

enum StreakCalculator {
    static func currentStreak(
        sessions: [Session],
        profile: UserProfile,
        forgivenessWindow: Int = 0,
        today: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        let hasAnyWorkoutDay = profile.weeklySchedule.contains { $0.templateCategory != nil }
        guard hasAnyWorkoutDay else { return 0 }

        let sessionDays: Set<DateComponents> = Set(sessions.map {
            calendar.dateComponents([.year, .month, .day], from: $0.date)
        })

        var cursor = calendar.startOfDay(for: today)
        var streak = 0
        var forgivenessRemaining = max(0, forgivenessWindow)
        // Cap the walk at ~1 year; it's a safety net, not a real limit users hit.
        for _ in 0..<400 {
            let components = calendar.dateComponents([.year, .month, .day], from: cursor)
            let isToday = calendar.isDate(cursor, inSameDayAs: today)

            let hasSession = sessionDays.contains(components)
            let weekday = Weekday.from(date: cursor, calendar: calendar)
            let entry = profile.weeklySchedule.first { $0.weekday == weekday }
            // Invariant: every weekday has an entry. A missing entry would
            // mean the schedule was mutated outside normalizeWeeklySchedule;
            // treat it as a workout day (streak-breaking) so the bug is
            // visible rather than silently extending the streak.
            let isScheduledRest = entry.map { $0.templateCategory == nil } ?? false

            if hasSession || isScheduledRest {
                streak += 1
            } else if isToday {
                // Today hasn't failed yet — user still has time. Skip without breaking.
            } else if forgivenessRemaining > 0 {
                forgivenessRemaining -= 1
            } else {
                break
            }

            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streak
    }
}
