//
//  MuscleWeight.swift
//  MotivateMe
//
//  A (muscle, contribution) pair used in Exercise.primaryMuscles and
//  secondaryMuscles. `weight` is 0.0 – 1.0 representing how much the
//  movement loads that muscle; used for body-area volume calculations.
//

import Foundation

struct MuscleWeight: Codable, Hashable {
    var muscle: MuscleGroup
    var weight: Double
}
