//
//  TemplateRecommender.swift
//  MotivateMe
//
//  Picks a workout template from the library that matches a target
//  category and the user's equipment + experience. Produces either a
//  single recommendation or the full ranked list — the latter powers the
//  swap screen so the user can see alternatives.
//
//  Ranking: higher minimum experience first (so a casual user gets
//  "casual"-tier templates, not beginner ones when qualified), ties broken
//  by shorter duration first (sustainable-health bias: prefer a 30-min
//  session over a 45-min one when they're otherwise equivalent).
//

import Foundation

enum TemplateRecommender {
    static func recommend(category: TemplateCategory, for profile: UserProfile) -> WorkoutTemplate? {
        candidates(category: category, for: profile).first
    }

    static func candidates(category: TemplateCategory, for profile: UserProfile) -> [WorkoutTemplate] {
        let userEquipment = Set(profile.availableEquipment)
        let userRank = profile.experienceLevel.rank

        return LibraryStore.shared.workoutTemplates.values
            .filter { $0.templateCategory == category }
            .filter { $0.minimumExperienceLevel.rank <= userRank }
            .filter { Set($0.requiredEquipment).isSubset(of: userEquipment) }
            .sorted { lhs, rhs in
                if lhs.minimumExperienceLevel.rank != rhs.minimumExperienceLevel.rank {
                    return lhs.minimumExperienceLevel.rank > rhs.minimumExperienceLevel.rank
                }
                return lhs.targetDurationMinutes < rhs.targetDurationMinutes
            }
    }
}
