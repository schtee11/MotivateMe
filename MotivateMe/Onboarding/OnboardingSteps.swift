//
//  OnboardingSteps.swift
//  MotivateMe
//
//  Individual step views for the onboarding wizard. Each view reads/writes
//  a shared OnboardingDraft; OnboardingView is responsible for step order,
//  validation, and the final save.
//
//  Morning Light styling: a soft sunrise mark on the welcome step, large
//  rounded titles, and SelectableRows with iconed tiles + check pills.
//

import SwiftUI

// MARK: - Welcome

struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 24)
            sunriseMark
                .padding(.bottom, 28)
            MMEyebrow(text: "MotivateMe")
                .padding(.bottom, 12)
            Text("A little better,\nmost days.")
                .font(.system(size: 32, weight: .semibold, design: .serif))
                .italic()
                .foregroundStyle(MMColor.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 16)
            Text("A quiet companion for the small habits that add up. No streaks lost, no shaming, no noise.")
                .font(MMFont.body)
                .foregroundStyle(MMColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 14)
                .padding(.horizontal, 24)
            Spacer(minLength: 24)
        }
        .frame(maxWidth: .infinity)
    }

    private var sunriseMark: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [MMColor.primary, MMColor.primaryTint, .clear],
                        center: .center, startRadius: 4, endRadius: 90
                    )
                )
                .frame(width: 160, height: 160)

            Circle()
                .fill(MMColor.primary)
                .frame(width: 64, height: 64)
                .mmShadow(.glow)

            // Horizon line
            Rectangle()
                .fill(MMColor.secondary.opacity(0.35))
                .frame(height: 1)
                .padding(.horizontal, 18)
                .offset(y: 44)
        }
        .frame(width: 160, height: 160)
    }
}

// MARK: - Goals

struct GoalsStep: View {
    @Bindable var draft: OnboardingDraft

    private let blurbs: [Goal: String] = [
        .buildHabit:    "Show up most days, kindly.",
        .loseWeight:    "Slow and steady, no crash plans.",
        .getStronger:   "Build strength over time.",
        .generalHealth: "Move, breathe, feel better."
    ]

    private let icons: [Goal: String] = [
        .buildHabit:    "leaf.fill",
        .loseWeight:    "figure.walk",
        .getStronger:   "dumbbell.fill",
        .generalHealth: "heart.fill"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StepHeader(
                title: "What brings you here?",
                subtitle: "Pick any that feel true. You can change your mind anytime."
            )

            VStack(spacing: 8) {
                ForEach(Goal.allCases, id: \.self) { goal in
                    SelectableRow(
                        icon: icons[goal] ?? "circle",
                        label: goal.displayName,
                        detail: blurbs[goal],
                        isSelected: draft.goals.contains(goal),
                        showsCheck: true,
                        action: { toggle(goal) }
                    )
                }
            }
            .padding(.top, 22)
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

    private let icons: [ExperienceLevel: String] = [
        .firstTime: "sparkles",
        .returning: "arrow.uturn.backward",
        .casual:    "figure.flexibility",
        .serious:   "flame.fill"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StepHeader(
                title: "How does training feel right now?",
                subtitle: "We'll pick weights and volume that match where you are."
            )

            VStack(spacing: 8) {
                ForEach(ExperienceLevel.allCases, id: \.self) { level in
                    SelectableRow(
                        icon: icons[level] ?? "circle",
                        label: level.displayName,
                        detail: level.descriptionText,
                        isSelected: draft.experienceLevel == level,
                        showsCheck: false,
                        action: { draft.experienceLevel = level }
                    )
                }
            }
            .padding(.top, 22)
        }
    }
}

// MARK: - Equipment

struct EquipmentStep: View {
    @Bindable var draft: OnboardingDraft

    private let icons: [Equipment: String] = [
        .dumbbells:       "dumbbell.fill",
        .barbell:         "figure.strengthtraining.traditional",
        .bench:           "rectangle.fill",
        .pullUpBar:       "figure.pull.up.bar",
        .resistanceBands: "scribble.variable",
        .kettlebells:     "circle.hexagongrid.fill",
        .cableMachine:    "arrow.up.and.down.and.arrow.left.and.right"
    ]

    private var selectableEquipment: [Equipment] {
        Equipment.allCases.filter { $0 != .none }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StepHeader(
                title: "What do you have access to?",
                subtitle: "Pick everything that applies. Bodyweight-only is fine."
            )

            VStack(spacing: 8) {
                SelectableRow(
                    icon: "checkmark.seal.fill",
                    label: "All equipment",
                    detail: "Treat me like a full gym.",
                    isSelected: allSelected,
                    showsCheck: true,
                    action: toggleAll
                )

                ForEach(selectableEquipment, id: \.self) { equipment in
                    SelectableRow(
                        icon: icons[equipment] ?? "circle",
                        label: equipment.displayName,
                        detail: nil,
                        isSelected: draft.availableEquipment.contains(equipment),
                        showsCheck: true,
                        action: { toggle(equipment) }
                    )
                }
            }
            .padding(.top, 22)
        }
    }

    private var allSelected: Bool {
        draft.availableEquipment.count == selectableEquipment.count
    }

    private func toggle(_ equipment: Equipment) {
        if draft.availableEquipment.contains(equipment) {
            draft.availableEquipment.remove(equipment)
        } else {
            draft.availableEquipment.insert(equipment)
        }
    }

    private func toggleAll() {
        if allSelected {
            draft.availableEquipment.removeAll()
        } else {
            draft.availableEquipment = Set(selectableEquipment)
        }
    }
}

// MARK: - Schedule

struct ScheduleStep: View {
    @Bindable var draft: OnboardingDraft

    private let sessionLengthOptions: [Int] = [15, 30, 45, 60, 75]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StepHeader(
                title: "Let's plan your week",
                subtitle: "Rough targets — you can always swap a day."
            )

            VStack(spacing: 14) {
                MMCard(tone: .surface, radius: 18, padding: 16, shadow: .xs) {
                    HStack(spacing: 12) {
                        iconTile("calendar", color: MMColor.primary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Days per week")
                                .font(MMFont.callout)
                                .foregroundStyle(MMColor.textPrimary)
                            Text("A rhythm that fits real life.")
                                .font(MMFont.caption1)
                                .foregroundStyle(MMColor.textTertiary)
                        }
                        Spacer()
                        Stepper(value: $draft.daysPerWeek, in: 1...7) {
                            Text("\(draft.daysPerWeek)")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(MMColor.textPrimary)
                                .monospacedDigit()
                        }
                        .labelsHidden()
                        .tint(MMColor.primary)
                    }
                }

                MMCard(tone: .surface, radius: 18, padding: 16, shadow: .xs) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 12) {
                            iconTile("rectangle.split.3x1.fill", color: MMColor.secondary)
                            Text("Split style")
                                .font(MMFont.callout)
                                .foregroundStyle(MMColor.textPrimary)
                            Spacer()
                        }

                        VStack(spacing: 6) {
                            ForEach(SplitStyle.allCases, id: \.self) { style in
                                splitChip(style)
                            }
                        }

                        Text(draft.splitStyle.descriptionText)
                            .font(MMFont.footnote)
                            .foregroundStyle(MMColor.textSecondary)
                            .padding(.top, 2)
                    }
                }

                MMCard(tone: .surface, radius: 18, padding: 16, shadow: .xs) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 12) {
                            iconTile("clock.fill", color: MMColor.primary)
                            Text("Session length")
                                .font(MMFont.callout)
                                .foregroundStyle(MMColor.textPrimary)
                            Spacer()
                        }

                        HStack(spacing: 6) {
                            ForEach(sessionLengthOptions, id: \.self) { minutes in
                                lengthChip(minutes)
                            }
                        }
                    }
                }
            }
            .padding(.top, 22)
        }
    }

    private func splitChip(_ style: SplitStyle) -> some View {
        let isSelected = draft.splitStyle == style
        return Button {
            draft.splitStyle = style
        } label: {
            HStack {
                Text(style.displayName)
                    .font(MMFont.callout)
                    .foregroundStyle(isSelected ? MMColor.primary : MMColor.textPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(MMColor.primary)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? MMColor.primaryTint : MMColor.surfaceInput)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(isSelected ? MMColor.primary : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func lengthChip(_ minutes: Int) -> some View {
        let isSelected = draft.sessionLengthMinutes == minutes
        return Button {
            draft.sessionLengthMinutes = minutes
        } label: {
            Text("\(minutes)")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isSelected ? MMColor.primaryTint : MMColor.surfaceInput)
                )
                .foregroundStyle(isSelected ? MMColor.primary : MMColor.textSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(isSelected ? MMColor.primary : .clear, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
    }

    private func iconTile(_ name: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(color.opacity(0.16))
                .frame(width: 32, height: 32)
            Image(systemName: name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
        }
    }
}

// MARK: - Units

struct UnitsStep: View {
    @Bindable var draft: OnboardingDraft

    private let weightUnits: [(unit: Unit, sub: String)] = [
        (.pounds,    "Inches for measurements."),
        (.kilograms, "Centimeters for measurements.")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StepHeader(
                title: "Which units do you prefer?",
                subtitle: "Used for tracking weights and measurements."
            )

            VStack(spacing: 8) {
                ForEach(weightUnits, id: \.unit) { item in
                    SelectableRow(
                        icon: "scalemass.fill",
                        label: item.unit.displayName,
                        detail: item.sub,
                        isSelected: draft.preferredUnit == item.unit,
                        showsCheck: false,
                        action: { draft.preferredUnit = item.unit }
                    )
                }
            }
            .padding(.top, 22)
        }
    }
}

// MARK: - Summary

struct SummaryStep: View {
    @Bindable var draft: OnboardingDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [MMColor.primary.opacity(0.30), .clear],
                            center: .center, startRadius: 4, endRadius: 70
                        )
                    )
                    .frame(width: 128, height: 128)
                Circle()
                    .fill(MMColor.primary)
                    .frame(width: 84, height: 84)
                    .mmShadow(.glow)
                Image(systemName: "checkmark")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(MMColor.onPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
            .padding(.bottom, 22)

            Text("You're all set.")
                .font(.system(size: 30, weight: .semibold, design: .serif))
                .italic()
                .foregroundStyle(MMColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)

            Text("Today counts as day one.")
                .font(MMFont.body)
                .foregroundStyle(MMColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
                .padding(.horizontal, 24)

            VStack(spacing: 8) {
                summaryRow(label: "Goals", value: goalsText, icon: "leaf.fill")
                summaryRow(label: "Experience", value: draft.experienceLevel.displayName, icon: "figure.flexibility")
                summaryRow(label: "Equipment", value: equipmentText, icon: "dumbbell.fill")
                summaryRow(label: "Schedule",
                           value: "\(draft.daysPerWeek)× / week · \(draft.splitStyle.displayName)",
                           icon: "calendar")
                summaryRow(label: "Session", value: "\(draft.sessionLengthMinutes) min", icon: "clock.fill")
                summaryRow(label: "Units", value: draft.preferredUnit.displayName, icon: "scalemass.fill")
            }
            .padding(.top, 24)

            HStack(spacing: 12) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(MMColor.secondary)
                Text("Miss a day? Nothing breaks. We pick up where you left off.")
                    .font(MMFont.footnote)
                    .foregroundStyle(MMColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(MMColor.secondaryTint)
            )
            .padding(.top, 18)
        }
    }

    private func summaryRow(label: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(MMColor.primaryTint)
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(MMColor.primary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(label.uppercased())
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .tracking(0.6)
                    .foregroundStyle(MMColor.textTertiary)
                Text(value)
                    .font(MMFont.callout)
                    .foregroundStyle(MMColor.textPrimary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(MMColor.surfaceCard)
        )
        .mmShadow(.xs)
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
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(MMFont.largeTitle)
                .foregroundStyle(MMColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            if let subtitle {
                Text(subtitle)
                    .font(MMFont.body)
                    .foregroundStyle(MMColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SelectableRow: View {
    var icon: String
    let label: String
    var detail: String?
    let isSelected: Bool
    /// True for multi-select rows (check), false for single-select (filled tile only).
    var showsCheck: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isSelected ? MMColor.primary : MMColor.primaryMuted)
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isSelected ? MMColor.onPrimary : MMColor.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(MMColor.textPrimary)
                    if let detail {
                        Text(detail)
                            .font(MMFont.footnote)
                            .foregroundStyle(MMColor.textSecondary)
                    }
                }

                Spacer(minLength: 8)

                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? .clear : MMColor.border, lineWidth: 1.5)
                        .background(Circle().fill(isSelected ? MMColor.primary : .clear))
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Image(systemName: showsCheck ? "checkmark" : "circle.fill")
                            .font(.system(size: showsCheck ? 11 : 8, weight: .bold))
                            .foregroundStyle(MMColor.onPrimary)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? MMColor.primaryTint : MMColor.surfaceCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isSelected ? MMColor.primary : .clear, lineWidth: 1.5)
            )
            .mmShadow(.xs)
        }
        .buttonStyle(.plain)
    }
}
