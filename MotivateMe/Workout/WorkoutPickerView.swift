//
//  WorkoutPickerView.swift
//  MotivateMe
//
//  Library browser for picking any workout the user qualifies for. Used
//  for "swap today's workout" and "pick a workout on a rest day."
//  Groups templates by category; tapping one returns it via onPick and
//  dismisses. Caller is responsible for then presenting ActiveWorkoutView.
//

import SwiftUI

struct WorkoutPickerView: View {
    let profile: UserProfile
    // Optional pre-filter applied on top of the user's available
    // templates. Used when readiness is low to surface only easier
    // options without yanking the full library.
    var initialEffortFilter: EffortLevel? = nil
    let onPick: (WorkoutTemplate) -> Void

    @Environment(\.dismiss) private var dismiss

    private var grouped: [(category: TemplateCategory, templates: [WorkoutTemplate])] {
        var all = TemplateRecommender.allCandidates(for: profile)
        if let effort = initialEffortFilter {
            all = all.filter { $0.effortLevel == effort }
        }
        let byCategory = Dictionary(grouping: all, by: \.templateCategory)
        return byCategory
            .map { (category: $0.key, templates: $0.value) }
            .sorted { $0.category.sortOrder < $1.category.sortOrder }
    }

    private var navigationTitle: String {
        initialEffortFilter == .easy ? "Lighter options" : "Pick a workout"
    }

    var body: some View {
        NavigationStack {
            Group {
                if grouped.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle(navigationTitle)
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
            ForEach(grouped, id: \.category) { group in
                Section(group.category.displayName) {
                    ForEach(group.templates) { template in
                        Button {
                            onPick(template)
                            dismiss()
                        } label: {
                            TemplateRow(template: template)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "dumbbell")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("No workouts match your profile")
                .font(.headline)
            Text("Add equipment or adjust your experience level in Settings.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

private struct TemplateRow: View {
    let template: WorkoutTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(template.name)
                .font(.headline)
                .foregroundStyle(.primary)
            if let summary = template.summary {
                Text(summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            HStack(spacing: 12) {
                Label("\(template.targetDurationMinutes) min", systemImage: "clock")
                Label("\(template.exerciseSlots.count) exercises", systemImage: "list.bullet")
            }
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
