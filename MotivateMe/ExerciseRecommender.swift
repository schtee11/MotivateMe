//
//  ExerciseRecommender.swift
//  MotivateMe
//
//  Picks alternates for a single exercise within an active workout. Scoped
//  narrower than TemplateRecommender: movement-pattern match only (not
//  muscle-group), because mid-workout swaps are usually "same role,
//  different implement" (e.g. barbell squat → goblet squat).
//

import Foundation

enum ExerciseRecommender {
    static func alternates(
        forPattern pattern: MovementPattern,
        excluding excludedId: UUID?,
        profile: UserProfile
    ) -> [Exercise] {
        let userEquipment = Set(profile.availableEquipment)
        return LibraryStore.shared.exercises.values
            .filter { $0.movementPattern == pattern }
            .filter { $0.id != excludedId }
            .filter { Set($0.requiredEquipment).isSubset(of: userEquipment) }
            .sorted { $0.name < $1.name }
    }
}
