//
//  Enums.swift
//  MotivateMe
//
//  Shared enumerations used across models, views, and persistence.
//  All are String-backed for CloudKit debuggability and SwiftData predicate support.
//

import Foundation

enum Goal: String, Codable, CaseIterable {
    case buildHabit, loseWeight, getStronger, generalHealth
}

enum ExperienceLevel: String, Codable, CaseIterable {
    case firstTime, returning, casual, serious
}

enum SplitStyle: String, Codable, CaseIterable {
    case fullBody, upperLower, pushPullLegs
}

enum Equipment: String, Codable, CaseIterable {
    case dumbbells, barbell, bench, pullUpBar, resistanceBands, kettlebells, cableMachine, none
}

enum Weekday: String, Codable, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

enum Unit: String, Codable, CaseIterable {
    case pounds, kilograms, inches, centimeters
}

enum MovementPattern: String, Codable, CaseIterable {
    case squat, hinge, horizontalPush, verticalPush, horizontalPull, verticalPull, core, carry, mobility
}

enum MuscleGroup: String, Codable, CaseIterable {
    case chest, back, shoulders, biceps, triceps, quads, hamstrings, glutes, calves, core, forearms
}

enum DifficultyTier: String, Codable, CaseIterable {
    case tier1, tier2, tier3
}

enum EffortLevel: String, Codable, CaseIterable {
    case easy, moderate, hard
}

enum SessionStatus: String, Codable, CaseIterable {
    case completed, partial, skipped, restDayLogged, upcoming
}

enum Contraindication: String, Codable, CaseIterable {
    case lowerBack, knees, shoulders, wrists
}

enum ReadinessSource: String, Codable, CaseIterable {
    case oura, healthKit, selfReport, none
}

// Used to sub-categorize WorkoutTemplate beyond SplitStyle, so the Today screen
// can recommend e.g. "upper" vs "lower" within an upperLower split.
enum TemplateCategory: String, Codable, CaseIterable {
    case fullBody, upper, lower, push, pull, legs, mobility
}

// Whether an ExerciseSlot's target is a rep count or a hold duration.
// Example: a squat slot uses .reps (8–12); a plank slot uses .seconds (20–45).
enum SlotTargetType: String, Codable, CaseIterable {
    case reps, seconds
}
