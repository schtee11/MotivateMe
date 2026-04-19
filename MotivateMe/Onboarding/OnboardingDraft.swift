//
//  OnboardingDraft.swift
//  MotivateMe
//
//  In-progress selections during onboarding. Held as an @Observable class so
//  SwiftUI views can read and mutate it across steps without passing a
//  `@Binding` for every field. `apply(to:)` writes the final values onto a
//  persisted UserProfile when the user finishes.
//
//  Uses `Set` for multi-selects (goals, equipment) for constant-time toggles;
//  converts to `Array` only when materializing into the stored model.
//

import Foundation

@Observable
final class OnboardingDraft {
    var goals: Set<Goal> = []
    var experienceLevel: ExperienceLevel = .firstTime
    var availableEquipment: Set<Equipment> = []
    var daysPerWeek: Int = 3
    var splitStyle: SplitStyle = .fullBody
    var sessionLengthMinutes: Int = 30
    var preferredUnit: Unit = .pounds

    func apply(to profile: UserProfile) {
        profile.goals = Array(goals)
        profile.experienceLevel = experienceLevel
        profile.availableEquipment = Array(availableEquipment)
        profile.daysPerWeek = daysPerWeek
        profile.splitStyle = splitStyle
        profile.sessionLengthMinutes = sessionLengthMinutes
        profile.preferredUnit = preferredUnit
        profile.updatedAt = Date()
    }
}
