//
//  Exercise.swift
//  MotivateMe
//
//  Library data. Seeded from bundled exercises.json at launch, held in memory
//  by LibraryStore. Not a SwiftData @Model — see the spec: library data is
//  immutable after seed and referenced by UUID from Session data.
//

import Foundation

struct Exercise: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var movementPattern: MovementPattern
    var primaryMuscles: [MuscleWeight]
    var secondaryMuscles: [MuscleWeight]
    var requiredEquipment: [Equipment]
    var difficultyTier: DifficultyTier
    var regressionExerciseId: UUID?
    var progressionExerciseId: UUID?
    var contraindications: [Contraindication]
    var formCues: [String]
    var demoVideoURL: URL?
    var instructions: String
    var isSelfLimiting: Bool
}
