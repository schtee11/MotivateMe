//
//  ExercisePickerView.swift
//  MotivateMe
//
//  Mid-workout "swap exercise" picker. Filters the library to exercises of
//  the same movement pattern that fit the user's equipment. Read-only list
//  — selection fires onPick and dismisses; caller rebinds the draft.
//

import SwiftUI

struct ExercisePickerView: View {
    let profile: UserProfile
    let movementPattern: MovementPattern
    let currentExerciseId: UUID?
    let onPick: (Exercise) -> Void

    @Environment(\.dismiss) private var dismiss

    private var alternates: [Exercise] {
        ExerciseRecommender.alternates(
            forPattern: movementPattern,
            excluding: currentExerciseId,
            profile: profile
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if alternates.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Swap exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var list: some View {
        List {
            ForEach(alternates) { exercise in
                Button {
                    onPick(exercise)
                    dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(exercise.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        if !exercise.requiredEquipment.isEmpty {
                            Text(equipmentList(exercise.requiredEquipment))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No alternates")
                .font(.headline)
            Text("No other \(movementPattern.label) exercises match your equipment.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func equipmentList(_ equipment: [Equipment]) -> String {
        equipment.map(\.displayName).joined(separator: " · ")
    }
}

private extension MovementPattern {
    var label: String {
        switch self {
        case .squat:          return "squat"
        case .hinge:          return "hinge"
        case .horizontalPush: return "horizontal push"
        case .verticalPush:   return "vertical push"
        case .horizontalPull: return "horizontal pull"
        case .verticalPull:   return "vertical pull"
        case .core:           return "core"
        case .carry:          return "carry"
        case .mobility:       return "mobility"
        }
    }
}
