//
//  ActiveWorkoutView.swift
//  MotivateMe
//
//  Full-screen workout logger ("logger" in the Morning Light design).
//  Builds a WorkoutDraft from the template, scrolls through each
//  exercise's sets, and either saves a Session on Finish or discards on
//  Cancel.
//
//  Each set lives on a row with a grid of: set number · stepper ·
//  weight field · done circle. A rest pill drops in from the bottom
//  whenever a set is marked complete.
//

import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var draft: WorkoutDraft
    @State private var restTimer = RestTimer()
    @State private var showingDiscardConfirmation: Bool = false
    @State private var showingFinishSheet: Bool = false
    let profile: UserProfile
    let previousSession: Session?

    init(template: WorkoutTemplate, profile: UserProfile, previousSession: Session? = nil) {
        _draft = State(initialValue: WorkoutDraft(template: template, previousSession: previousSession))
        self.profile = profile
        self.previousSession = previousSession
    }

    var body: some View {
        @Bindable var draft = draft

        return NavigationStack {
            ZStack(alignment: .bottom) {
                MMColor.bg.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header

                        ForEach(draft.exerciseDrafts.indices, id: \.self) { index in
                            ExerciseCard(
                                draft: $draft.exerciseDrafts[index],
                                weightUnit: profile.preferredUnit,
                                restTimer: restTimer,
                                profile: profile
                            )
                        }

                        MMPillButton(
                            variant: .primary,
                            icon: "checkmark",
                            title: "Finish workout"
                        ) { showingFinishSheet = true }
                        .padding(.top, 6)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                    .padding(.bottom, restTimer.isRunning ? 96 : 32)
                }

                if restTimer.isRunning {
                    RestBar(timer: restTimer)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: restTimer.isRunning)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(draft.template.name)
                        .font(MMFont.headline)
                        .foregroundStyle(MMColor.textPrimary)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        showingDiscardConfirmation = true
                    }
                    .foregroundStyle(MMColor.primary)
                }
            }
            .confirmationDialog(
                "Discard this workout?",
                isPresented: $showingDiscardConfirmation,
                titleVisibility: .visible
            ) {
                Button("Discard", role: .destructive) { dismiss() }
                Button("Keep going", role: .cancel) {}
            } message: {
                Text("Nothing will be saved.")
            }
            .sheet(isPresented: $showingFinishSheet) {
                FinishWorkoutSheet { effort, notes in
                    draft.save(to: modelContext, effort: effort, notes: notes)
                    dismiss()
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let summary = draft.template.summary {
                Text(summary)
                    .font(MMFont.subhead)
                    .foregroundStyle(MMColor.textSecondary)
            }
            HStack(spacing: 12) {
                Label("\(draft.template.targetDurationMinutes) min", systemImage: "clock")
                Label("\(draft.template.exerciseSlots.count) exercises", systemImage: "list.bullet")
            }
            .font(MMFont.footnote)
            .foregroundStyle(MMColor.textTertiary)

            if let lastTimeText {
                Label(lastTimeText, systemImage: "clock.arrow.circlepath")
                    .font(MMFont.caption1)
                    .foregroundStyle(MMColor.textSecondary)
                    .padding(.top, 2)
            }
        }
        .padding(.bottom, 2)
    }

    private var lastTimeText: String? {
        guard let previousSession else { return nil }

        var parts: [String] = []
        let daysAgo = daysSince(previousSession.date)
        if daysAgo == 0 {
            parts.append("earlier today")
        } else if daysAgo == 1 {
            parts.append("yesterday")
        } else {
            parts.append("\(daysAgo) days ago")
        }

        if let seconds = previousSession.durationSeconds, seconds > 0 {
            parts.append("\(seconds / 60) min")
        }
        if let rating = previousSession.effortRating,
           let effort = EffortLevel(rating: rating) {
            parts.append(effort.displayName.lowercased())
        }
        return "Last: " + parts.joined(separator: " · ")
    }

    private func daysSince(_ date: Date) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: Date())
        return calendar.dateComponents([.day], from: start, to: today).day ?? 0
    }
}

// MARK: - Exercise card

private struct ExerciseCard: View {
    @Binding var draft: ExerciseDraft
    let weightUnit: Unit
    let restTimer: RestTimer
    let profile: UserProfile

    @State private var showingExercisePicker: Bool = false
    @State private var showingExerciseHistory: Bool = false

    var body: some View {
        MMCard(tone: .surface, radius: 20, padding: 16, shadow: .sm) {
            VStack(alignment: .leading, spacing: 14) {
                header

                if !draft.skipped {
                    if let cues = draft.exercise?.formCues, !cues.isEmpty {
                        Text(cues.joined(separator: " · "))
                            .font(MMFont.caption1)
                            .foregroundStyle(MMColor.textTertiary)
                    }

                    VStack(spacing: 8) {
                        ForEach(draft.sets.indices, id: \.self) { setIndex in
                            SetRow(
                                set: $draft.sets[setIndex],
                                targetType: draft.slot.targetType,
                                weightUnit: weightUnit,
                                restSeconds: draft.slot.restSeconds,
                                restTimer: restTimer,
                                canRemove: setIndex >= draft.slot.sets,
                                onRemove: { draft.removeSet(id: draft.sets[setIndex].id) }
                            )
                        }

                        Button {
                            draft.addSet()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle")
                                Text("Add set")
                            }
                            .font(MMFont.footnote)
                            .foregroundStyle(MMColor.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 2)
                    }

                    if draft.hasAnyCompletedSet {
                        effortStrip
                            .padding(.top, 2)
                    }
                }
            }
        }
        .opacity(draft.skipped ? 0.55 : 1)
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerView(
                profile: profile,
                movementPattern: draft.slot.movementPattern,
                currentExerciseId: draft.currentExerciseId
            ) { picked in
                draft.currentExerciseId = picked.id
            }
        }
        .sheet(isPresented: $showingExerciseHistory) {
            ExerciseHistoryView(exerciseId: draft.currentExerciseId)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            Button {
                showingExerciseHistory = true
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(draft.exercise?.name ?? "Exercise")
                            .font(MMFont.headline)
                            .foregroundStyle(MMColor.textPrimary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(MMColor.textTertiary)
                    }
                    Text(draft.targetDescription)
                        .font(MMFont.caption1)
                        .foregroundStyle(MMColor.textSecondary)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Menu {
                Button {
                    showingExercisePicker = true
                } label: {
                    Label("Swap exercise", systemImage: "arrow.left.arrow.right")
                }
                Button(role: draft.skipped ? nil : .destructive) {
                    draft.skipped.toggle()
                } label: {
                    Label(
                        draft.skipped ? "Unskip" : "Skip exercise",
                        systemImage: draft.skipped ? "arrow.uturn.backward" : "xmark"
                    )
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(MMColor.textTertiary)
            }
            .menuStyle(.borderlessButton)
        }
    }

    private var effortStrip: some View {
        HStack(spacing: 6) {
            Text("Felt")
                .font(MMFont.caption1)
                .foregroundStyle(MMColor.textTertiary)
            ForEach([EffortLevel.easy, .moderate, .hard], id: \.self) { level in
                Button {
                    draft.effort = (draft.effort == level) ? nil : level
                } label: {
                    Text(level.displayName)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .padding(.horizontal, 11)
                        .padding(.vertical, 5)
                        .background(
                            Capsule().fill(
                                draft.effort == level
                                    ? MMColor.primaryMuted
                                    : MMColor.surfaceInput
                            )
                        )
                        .foregroundStyle(draft.effort == level ? MMColor.primary : MMColor.textSecondary)
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }
}

// MARK: - Set row

private struct SetRow: View {
    @Binding var set: SetDraft
    let targetType: SlotTargetType
    let weightUnit: Unit
    let restSeconds: Int
    let restTimer: RestTimer
    let canRemove: Bool
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Text("\(set.setNumber)")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(MMColor.textTertiary)
                .frame(width: 20, alignment: .leading)

            countControls

            Spacer()

            weightField

            Button {
                let wasCompleted = set.completed
                set.completed.toggle()
                if !wasCompleted {
                    restTimer.start(seconds: restSeconds)
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(set.completed ? MMColor.secondary : MMColor.surfaceInput)
                    if set.completed {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.white)
                    } else {
                        Circle()
                            .strokeBorder(MMColor.border, lineWidth: 1.5)
                    }
                }
                .frame(width: 38, height: 38)
            }
            .buttonStyle(.plain)

            if canRemove {
                Button(action: onRemove) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(MMColor.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private var countControls: some View {
        HStack(spacing: 6) {
            Button { decrementCount() } label: {
                Image(systemName: "minus.circle")
                    .font(.system(size: 20))
                    .foregroundStyle(MMColor.textSecondary)
            }
            .buttonStyle(.plain)

            Text(countValueText)
                .font(MMFont.counter)
                .foregroundStyle(MMColor.textPrimary)
                .frame(minWidth: 30)

            Button { incrementCount() } label: {
                Image(systemName: "plus.circle")
                    .font(.system(size: 20))
                    .foregroundStyle(MMColor.textSecondary)
            }
            .buttonStyle(.plain)

            Text(countUnitText)
                .font(MMFont.caption1)
                .foregroundStyle(MMColor.textTertiary)
        }
    }

    private var weightField: some View {
        VStack(alignment: .trailing, spacing: 2) {
            HStack(spacing: 4) {
                TextField("wt", value: $set.weight, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(MMFont.counter)
                    .foregroundStyle(MMColor.textPrimary)
                    .frame(width: 52)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(MMColor.surfaceInput)
                    )
                Text(weightUnitShort)
                    .font(MMFont.caption1)
                    .foregroundStyle(MMColor.textTertiary)
            }
            if let previous = set.previousWeight {
                Text("last \(formatWeight(previous))")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(MMColor.textTertiary)
            }
        }
    }

    private func formatWeight(_ weight: Double) -> String {
        weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", weight)
            : String(format: "%.1f", weight)
    }

    private var countValueText: String {
        switch targetType {
        case .reps:    return "\(set.reps ?? 0)"
        case .seconds: return "\(set.durationSeconds ?? 0)"
        }
    }

    private var countUnitText: String {
        targetType == .reps ? "reps" : "sec"
    }

    private var weightUnitShort: String {
        switch weightUnit {
        case .pounds:      return "lb"
        case .kilograms:   return "kg"
        case .inches:      return "in"
        case .centimeters: return "cm"
        }
    }

    private func incrementCount() {
        switch targetType {
        case .reps:    set.reps = (set.reps ?? 0) + 1
        case .seconds: set.durationSeconds = (set.durationSeconds ?? 0) + 5
        }
    }

    private func decrementCount() {
        switch targetType {
        case .reps:    set.reps = max(0, (set.reps ?? 0) - 1)
        case .seconds: set.durationSeconds = max(0, (set.durationSeconds ?? 0) - 5)
        }
    }
}

// MARK: - Rest bar

private struct RestBar: View {
    @Bindable var timer: RestTimer

    var body: some View {
        HStack(spacing: 14) {
            ProgressRing(
                progress: progress,
                size: 36, stroke: 3,
                color: MMColor.primary,
                trackColor: MMColor.primaryMuted
            ) {
                Image(systemName: "timer")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(MMColor.primary)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text("Breathe, then go again")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(MMColor.textPrimary)
                Text(formatted)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(MMColor.primary)
                    .monospacedDigit()
            }

            Spacer()

            HStack(spacing: 6) {
                adjustButton(label: "-15") { timer.adjust(by: -15) }
                adjustButton(label: "+15") { timer.adjust(by: 15) }
                Button {
                    timer.stop()
                } label: {
                    Text("Skip")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(MMColor.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(MMColor.primaryMuted))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule().fill(.regularMaterial)
                .overlay(Capsule().strokeBorder(MMColor.separator, lineWidth: 1))
        )
        .mmShadow(.lg)
    }

    private var progress: Double {
        let total = max(1, timer.totalSeconds)
        return 1.0 - Double(timer.remaining) / Double(total)
    }

    private var formatted: String {
        let minutes = timer.remaining / 60
        let seconds = timer.remaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func adjustButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(MMColor.textPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Capsule().fill(MMColor.surfaceInput))
        }
        .buttonStyle(.plain)
    }
}
