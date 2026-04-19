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
//  Today counts only if already satisfied; otherwise the walk starts at
//  yesterday so an active day in progress doesn't count as breaking the
//  streak.
//

import Foundation

enum StreakCalculator {
    static func currentStreak(
        sessions: [Session],
        profile: UserProfile,
        today: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        let sessionDays: Set<DateComponents> = Set(sessions.map {
            calendar.dateComponents([.year, .month, .day], from: $0.date)
        })

        var cursor = calendar.startOfDay(for: today)
        var streak = 0
        // Cap the walk at ~1 year; it's a safety net, not a real limit users hit.
        for _ in 0..<400 {
            let components = calendar.dateComponents([.year, .month, .day], from: cursor)
            let isToday = calendar.isDate(cursor, inSameDayAs: today)

            let hasSession = sessionDays.contains(components)
            let weekday = Weekday.from(date: cursor, calendar: calendar)
            let entry = profile.weeklySchedule.first { $0.weekday == weekday }
            let isScheduledRest = entry?.templateCategory == nil

            if hasSession || isScheduledRest {
                streak += 1
            } else if isToday {
                // Today hasn't failed yet — user still has time. Skip without breaking.
            } else {
                break
            }

            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streak
    }
}
