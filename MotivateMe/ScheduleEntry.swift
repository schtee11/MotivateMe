//
//  ScheduleEntry.swift
//  MotivateMe
//
//  One row in the user's weekly default schedule. A nil templateCategory
//  means a rest day. Stored as part of UserProfile.weeklySchedule.
//
//  Kept as a Codable struct (not a SwiftData @Model) — the whole schedule
//  is a single value attached to the profile, small enough to serialize
//  into the blob that SwiftData already stores for array properties.
//

import Foundation

struct ScheduleEntry: Codable, Hashable {
    var weekday: Weekday
    var templateCategory: TemplateCategory?
}
