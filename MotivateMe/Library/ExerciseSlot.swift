//
//  ExerciseSlot.swift
//  MotivateMe
//
//  Structural element within a WorkoutTemplate. A slot declares what kind of
//  movement belongs at this position (e.g. "horizontal push, 3 sets of 8–12")
//  and the default exercise; the app substitutes alternatives based on the
//  user's available equipment.
//

import Foundation

struct ExerciseSlot: Codable, Identifiable, Hashable {
    var id: UUID
    var order: Int
    var movementPattern: MovementPattern
    var fallbackExerciseId: UUID
    var sets: Int
    var repRangeMin: Int
    var repRangeMax: Int
    var restSeconds: Int
    var notes: String?
}
