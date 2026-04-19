//
//  WorkoutTemplate.swift
//  MotivateMe
//
//  Library data. A curated workout composed of ordered exercise slots.
//  Seeded from bundled workoutTemplates.json at launch.
//

import Foundation

struct WorkoutTemplate: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var splitStyle: SplitStyle
    var templateCategory: TemplateCategory
    var targetDurationMinutes: Int
    var effortLevel: EffortLevel
    var requiredEquipment: [Equipment]
    var minimumExperienceLevel: ExperienceLevel
    var exerciseSlots: [ExerciseSlot]
    var summary: String?
}
