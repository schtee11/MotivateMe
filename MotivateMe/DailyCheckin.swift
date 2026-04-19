//
//  DailyCheckin.swift
//  MotivateMe
//
//  One record per calendar day. Uniqueness is enforced at the write layer
//  via `upsert(for:in:)` rather than `@Attribute(.unique)` because CloudKit
//  forbids unique constraints.
//

import Foundation
import SwiftData

@Model
final class DailyCheckin {
    var id: UUID = UUID()
    var date: Date = Date()
    var isCommitmentDay: Bool = false
    var status: SessionStatus = SessionStatus.upcoming
    var sessionId: UUID?

    var readinessScore: Int?
    var readinessSource: ReadinessSource = ReadinessSource.none
    var hrvSnapshot: Double?
    var rhrSnapshot: Double?
    var sleepHoursSnapshot: Double?
    var selfReportedEnergy: String?

    init() {}
}

extension DailyCheckin {
    /// Returns the existing check-in for the calendar day containing `date`,
    /// or creates a new one if none exists. Caller is responsible for setting
    /// any fields beyond `date` on the returned instance.
    static func upsert(for date: Date, in context: ModelContext) throws -> DailyCheckin {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            // Calendar.date(byAdding:) returns nil only for pathological inputs;
            // fall back to a new record to avoid throwing on the happy path.
            let newCheckin = DailyCheckin()
            newCheckin.date = startOfDay
            context.insert(newCheckin)
            return newCheckin
        }

        let descriptor = FetchDescriptor<DailyCheckin>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < nextDay }
        )
        if let existing = try context.fetch(descriptor).first {
            return existing
        }

        let newCheckin = DailyCheckin()
        newCheckin.date = startOfDay
        context.insert(newCheckin)
        return newCheckin
    }
}
