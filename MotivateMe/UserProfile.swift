//
//  UserProfile.swift
//  MotivateMe
//
//  The user's preferences and onboarding state. Logically a singleton —
//  enforced via the static `current(in:)` accessor, not at the storage layer
//  (CloudKit merges can create duplicates under race conditions, so we
//  reconcile on read).
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    var goals: [Goal] = []
    var experienceLevel: ExperienceLevel = ExperienceLevel.firstTime
    var splitStyle: SplitStyle = SplitStyle.fullBody
    var daysPerWeek: Int = 3
    var committedDays: [Weekday] = []
    var availableEquipment: [Equipment] = []
    var sessionLengthMinutes: Int = 30
    var weeklySchedule: [ScheduleEntry] = []
    var contraindications: [Contraindication] = []
    var injuryNotes: String?
    var preferredUnit: Unit = Unit.pounds

    var notificationsEnabled: Bool = true
    var reminderTime: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
    var weeklyCheckinEnabled: Bool = true

    var healthKitConnected: Bool = false
    var ouraConnected: Bool = false
    var morningSelfReportEnabled: Bool = false

    var streakCount: Int = 0
    var streakFreezesAvailable: Int = 1
    var lastStreakFreezeUsedAt: Date?

    init() {}
}

extension UserProfile {
    static func current(in context: ModelContext) throws -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        let results = try context.fetch(descriptor)
        if results.count > 1 {
            for duplicate in results.dropFirst() { context.delete(duplicate) }
        }
        return results.first
    }

    /// Invariant: `weeklySchedule` must hold exactly one entry per `Weekday`.
    /// Fills any missing weekday with a rest entry and returns true if the
    /// schedule was modified (so callers can save the context).
    @MainActor
    @discardableResult
    func normalizeWeeklySchedule() -> Bool {
        let existing = Dictionary(uniqueKeysWithValues: weeklySchedule.map { ($0.weekday, $0) })
        let canonical = Weekday.allCases.map { weekday in
            existing[weekday] ?? ScheduleEntry(weekday: weekday, templateCategory: nil)
        }
        let changed = canonical.count != weeklySchedule.count
            || zip(canonical, weeklySchedule).contains { $0 != $1 }
        if changed {
            weeklySchedule = canonical
        }
        return changed
    }
}
