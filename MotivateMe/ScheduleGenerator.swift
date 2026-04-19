//
//  ScheduleGenerator.swift
//  MotivateMe
//
//  Produces a sensible default weekly schedule from (splitStyle, daysPerWeek).
//  The user can edit it later — this is just the starting point so they
//  don't face a blank week after onboarding.
//
//  Strategy: pick workout days from a canonical M–F–first table (keeps Sun
//  as the rest day most people expect), then rotate through the split's
//  category sequence across those days.
//

import Foundation

enum ScheduleGenerator {
    static func defaultSchedule(splitStyle: SplitStyle, daysPerWeek: Int) -> [ScheduleEntry] {
        let workoutDays = defaultWorkoutDays(count: daysPerWeek)
        let rotation = categoryRotation(for: splitStyle)

        var rotationIndex = 0
        return Weekday.allCases.map { weekday in
            guard workoutDays.contains(weekday), !rotation.isEmpty else {
                return ScheduleEntry(weekday: weekday, templateCategory: nil)
            }
            let category = rotation[rotationIndex % rotation.count]
            rotationIndex += 1
            return ScheduleEntry(weekday: weekday, templateCategory: category)
        }
    }

    // Canonical "start the week on Monday, train through Friday first, add
    // Saturday/Sunday only if needed" tables. Matches what most beginners
    // expect and leaves weekends free at low frequencies.
    private static func defaultWorkoutDays(count: Int) -> Set<Weekday> {
        let clamped = max(0, min(7, count))
        let tables: [[Weekday]] = [
            [],
            [.monday],
            [.monday, .thursday],
            [.monday, .wednesday, .friday],
            [.monday, .tuesday, .thursday, .friday],
            [.monday, .tuesday, .wednesday, .thursday, .friday],
            [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday],
            [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        ]
        return Set(tables[clamped])
    }

    private static func categoryRotation(for splitStyle: SplitStyle) -> [TemplateCategory] {
        switch splitStyle {
        case .fullBody:     return [.fullBody]
        case .upperLower:   return [.upper, .lower]
        case .pushPullLegs: return [.push, .pull, .legs]
        }
    }
}
