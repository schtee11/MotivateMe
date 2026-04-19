//
//  OnboardingSteps.swift
//  MotivateMe
//
//  Individual step views for the onboarding wizard. Each view reads/writes
//  a shared OnboardingDraft; OnboardingView is responsible for step order,
//  validation, and the final save.
//

import SwiftUI

// MARK: - Welcome

struct WelcomeStep: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer()
            Text("Welcome to MotivateMe")
                .font(.largeTitle).bold()
            Text("A sustainable approach to fitness. We'll ask a few quick questions to tailor workouts to you.")
                .font(.body)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Goals

struct GoalsStep: View {
    @Bindable var draft: OnboardingDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            StepHeader(
                title: "What brings you here?",
                subtitle: "Pick one or more. You can change this later."
            )

            ForEach(Goal.allCases, id: \.self) { goal in
                SelectableRow(
                    label: goal.displayName,
                    isSelected: draft.goals.contains(goal),
                    action: { toggle(goal) }
                )
            }

            Spacer()
        }
    }

    private func toggle(_ goal: Goal) {
        if draft.goals.contains(goal) {
            draft.goals.remove(goal)
        } else {
            draft.goals.insert(goal)
        }
    }
}

// MARK: - Experience

struct ExperienceStep: View {
    @Bindable var draft: OnboardingDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            StepHeader(
                title: "How would you describe your experience?",
                subtitle: "We'll pick appropriate starting weights and volume."
            )

            ForEach(ExperienceLevel.allCases, id: \.self) { level in
                SelectableRow(
                    label: level.displayName,
                    detail: level.descriptionText,
                    isSelected: draft.experienceLevel == level,
                    action: { draft.experienceLevel = level }
                )
            }

            Spacer()
        }
    }
}

// MARK: - Equipment

struct EquipmentStep: View {
    @Bindable var draft: OnboardingDraft

    // "none" is implicit when the set is empty, so we don't show it.
    private var selectableEquipment: [Equipment] {
        Equipment.allCases.filter { $0 != .none }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            StepHeader(
                title: "What do you have access to?",
                subtitle: "Pick everything that applies. Bodyweight-only workouts are fine too."
            )

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(selectableEquipment, id: \.self) { equipment in
                        SelectableRow(
                            label: equipment.displayName,
                            isSelected: draft.availableEquipment.contains(equipment),
                            action: { toggle(equipment) }
                        )
                    }
                }
            }
        }
    }

    private func toggle(_ equipment: Equipment) {
        if draft.availableEquipment.contains(equipment) {
            draft.availableEquipment.remove(equipment)
        } else {
            draft.availableEquipment.insert(equipment)
        }
    }
}

// MARK: - Schedule

struct ScheduleStep: View {
    @Bindable var draft: OnboardingDraft

    private let sessionLengthOptions: [Int] = [15, 30, 45, 60, 75]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            StepHeader(
                title: "Let's plan your week",
                subtitle: "Rough targets — you can always swap a day."
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Days per week").font(.headline)
                Stepper("\(draft.daysPerWeek) days", value: $draft.daysPerWeek, in: 1...7)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Split style").font(.headline)
                Picker("Split style", selection: $draft.splitStyle) {
                    ForEach(SplitStyle.allCases, id: \.self) { style in
                        Text(style.displayName).tag(style)
                    }
                }
                .pickerStyle(.segmented)
                Text(draft.splitStyle.descriptionText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Session length").font(.headline)
                Picker("Session length", selection: $draft.sessionLengthMinutes) {
                    ForEach(sessionLengthOptions, id: \.self) { minutes in
                        Text("\(minutes) min").tag(minutes)
                    }
                }
                .pickerStyle(.segmented)
            }

            Spacer()
        }
    }
}

// MARK: - Units

struct UnitsStep: View {
    @Bindable var draft: OnboardingDraft

    // Only weight units are user-picked here; length units are inferred
    // alongside weight elsewhere (pounds -> inches, kilograms -> cm).
    private let weightUnits: [Unit] = [.pounds, .kilograms]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            StepHeader(
                title: "Which units do you prefer?",
                subtitle: "Used for tracking weights and measurements."
            )

            Picker("Units", selection: $draft.preferredUnit) {
                ForEach(weightUnits, id: \.self) { unit in
                    Text(unit.displayName).tag(unit)
                }
            }
            .pickerStyle(.segmented)

            Spacer()
        }
    }
}

// MARK: - Summary

struct SummaryStep: View {
    @Bindable var draft: OnboardingDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            StepHeader(
                title: "You're all set",
                subtitle: "Tap Get started to save and head to your first workout."
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    SummaryRow(label: "Goals", value: goalsText)
                    SummaryRow(label: "Experience", value: draft.experienceLevel.displayName)
                    SummaryRow(label: "Equipment", value: equipmentText)
                    SummaryRow(label: "Schedule", value: "\(draft.daysPerWeek)× / week, \(draft.splitStyle.displayName)")
                    SummaryRow(label: "Session", value: "\(draft.sessionLengthMinutes) min")
                    SummaryRow(label: "Units", value: draft.preferredUnit.displayName)
                }
            }
        }
    }

    private var goalsText: String {
        draft.goals.isEmpty
            ? "None selected"
            : draft.goals.map(\.displayName).sorted().joined(separator: ", ")
    }

    private var equipmentText: String {
        draft.availableEquipment.isEmpty
            ? "Bodyweight only"
            : draft.availableEquipment.map(\.displayName).sorted().joined(separator: ", ")
    }
}

// MARK: - Shared components

private struct StepHeader: View {
    let title: String
    let subtitle: String?

    init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.title2).bold()
            if let subtitle {
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SelectableRow: View {
    let label: String
    var detail: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.body)
                        .foregroundStyle(.primary)
                    if let detail {
                        Text(detail)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                    .font(.title3)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct SummaryRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
