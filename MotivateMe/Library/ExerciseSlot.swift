//
//  ExerciseSlot.swift
//  MotivateMe
//
//  Structural element within a WorkoutTemplate. A slot declares what kind of
//  movement belongs at this position, the default exercise, and how many
//  sets × reps-or-seconds the user should perform; the app substitutes
//  alternatives based on the user's available equipment.
//
//  `targetType` switches the meaning of `targetRangeMin/Max` between rep
//  counts and hold durations in seconds — both units share the same pair of
//  Int fields to keep JSON and storage simple.
//

import Foundation

struct ExerciseSlot: Codable, Identifiable, Hashable {
    var id: UUID
    var order: Int
    var movementPattern: MovementPattern
    var fallbackExerciseId: UUID
    var sets: Int
    var targetType: SlotTargetType
    var targetRangeMin: Int
    var targetRangeMax: Int
    var restSeconds: Int
    var notes: String?
}
