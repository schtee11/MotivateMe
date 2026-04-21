//
//  ActiveWorkoutView.swift
//  MotivateMe
//
//  Full-screen workout logger. Presented as a cover from Today when the
//  user taps Start. Builds a WorkoutDraft from the template, scrolls
//  through each exercise's sets, and either saves a Session on Finish or
//  discards on Cancel.
//
//  Weight input is a TextField with a decimal pad; rep/duration input is
//  a stepper so you never leave the touch surface during a set.
//

import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ErrorPresenter.self) private var errorPresenter
    @Environment(\.scenePhase) private var scenePhase

    @State private var draft: WorkoutDraft
    @State private var restTimer = RestTimer()
    @State private var showingDiscardConfirmation: Bool = false
    @State private var showingFinishSheet: Bool = false
    let profile: UserProfile
    let previousSession: Session?

    init(
        template: WorkoutTemplate,
        profile: UserProfile,
        previousSession: Session? = nil,
        resumingFrom snapshot: WorkoutDraftSnapshot? = nil
    ) {
        let restored = snapshot.flatMap(WorkoutDraft.init(snapshot:))
        _draft = State(
            initialValue: restored ?? WorkoutDraft(template: template, previousSession: previousSession)
        )
        self.profile = profile
        self.previousSession = previousSession
    }

    var body: some View {
        // Inline @Bindable shadow: @State owns the @Observable instance,
        // but property-level bindings ($draft.exerciseDrafts[i]) only
        // project through a @Bindable reference.
        @Bindable var draft = draft

        return NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header

                        ForEach(draft.exerciseDrafts.indices, id: \.self) { index in
                            ExerciseCard(
                                draft: $draft.exerciseDrafts[index],
                                weightUnit: profile.preferredUnit,
                                restTimer: restTimer,
                                profile: profile
                            )
                        }

                        finishButton
                            .padding(.top, 8)
                    }
                    .padding()
                    .padding(.bottom, restTimer.isRunning ? 72 : 0)
                }

                if restTimer.isRunning {
                    RestTimerPill(timer: restTimer)
                        .padding(.bottom, 12)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: restTimer.isRunning)
            .onChange(of: scenePhase) { _, phase in
                switch phase {
                case .active:
                    restTimer.recompute()
                case .inactive, .background:
                    // Leaving the app — snapshot so a kill or memory eviction
                    // doesn't lose what the user has logged so far.
                    WorkoutDraftStore.save(draft.snapshot)
                @unknown default:
                    break
                }
            }
            .navigationTitle(draft.template.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        showingDiscardConfirmation = true
                    }
                }
            }
            .confirmationDialog(
                "Discard this workout?",
                isPresented: $showingDiscardConfirmation,
                titleVisibility: .visible
            ) {
                Button("Discard", role: .destructive) {
                    WorkoutDraftStore.clear()
                    dismiss()
                }
                Button("Keep going", role: .cancel) {}
            } message: {
                Text("Nothing will be saved.")
            }
            .sheet(isPresented: $showingFinishSheet) {
                FinishWorkoutSheet { effort, notes in
                    do {
                        try draft.save(to: modelContext, effort: effort, notes: notes)
                        WorkoutDraftStore.clear()
                        dismiss()
                    } catch {
                        errorPresenter.present(error, context: "Saving your workout")
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let summary = draft.template.summary {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text("\(draft.template.targetDurationMinutes) min · \(draft.template.exerciseSlots.count) exercises")
                .font(.footnote)
                .foregroundStyle(.tertiary)

            if let lastTimeText {
                HStack(spacing: 4) {
                    Image(systemName: "clock.arrow.circlepath")
                    Text(lastTimeText)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 2)
            }
        }
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

    private var finishButton: some View {
        Button {
            showingFinishSheet = true
        } label: {
            Text("Finish workout")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
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
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Button {
                    showingExerciseHistory = true
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(draft.exercise?.name ?? "Exercise")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        Text(draft.targetDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
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
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .menuStyle(.borderlessButton)
            }

            if !draft.skipped {
                if let cues = draft.exercise?.formCues, !cues.isEmpty {
                    Text(cues.joined(separator: " · "))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                VStack(spacing: 6) {
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
                        Label("Add set", systemImage: "plus.circle")
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                }

                if draft.hasAnyCompletedSet {
                    effortStrip
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.08))
        )
        .opacity(draft.skipped ? 0.5 : 1)
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

    private var effortStrip: some View {
        HStack(spacing: 6) {
            Text("Felt:")
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach([EffortLevel.easy, .moderate, .hard], id: \.self) { level in
                Button {
                    draft.effort = (draft.effort == level) ? nil : level
                } label: {
                    Text(level.displayName)
                        .font(.caption).bold()
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(
                                draft.effort == level
                                    ? Color.accentColor.opacity(0.2)
                                    : Color.secondary.opacity(0.1)
                            )
                        )
                        .foregroundStyle(draft.effort == level ? Color.accentColor : .secondary)
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
                .font(.caption).bold()
                .foregroundStyle(.secondary)
                .frame(width: 18, alignment: .leading)

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
                Image(systemName: set.completed ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(set.completed ? Color.accentColor : Color.secondary)
            }
            .buttonStyle(.plain)

            if canRemove {
                Button(action: onRemove) {
                    Image(systemName: "minus.circle.fill")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
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
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            Text(countValueText)
                .font(.body).monospacedDigit()
                .frame(minWidth: 28)

            Button { incrementCount() } label: {
                Image(systemName: "plus.circle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            Text(countUnitText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var weightField: some View {
        VStack(alignment: .trailing, spacing: 2) {
            HStack(spacing: 4) {
                TextField("Weight", value: $set.weight, format: .number, prompt: Text("wt"))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 46)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.secondary.opacity(0.35), lineWidth: 1)
                    )
                Text(weightUnitShort)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let previous = set.previousWeight {
                Text("last: \(formatWeight(previous))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private func formatWeight(_ weight: Double) -> String {
        weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", weight)
            : String(format: "%.1f", weight)
    }

    // MARK: - Helpers

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
        case .reps:
            set.reps = (set.reps ?? 0) + 1
        case .seconds:
            set.durationSeconds = (set.durationSeconds ?? 0) + 5
        }
    }

    private func decrementCount() {
        switch targetType {
        case .reps:
            set.reps = max(0, (set.reps ?? 0) - 1)
        case .seconds:
            set.durationSeconds = max(0, (set.durationSeconds ?? 0) - 5)
        }
    }
}

// MARK: - Rest timer pill

private struct RestTimerPill: View {
    @Bindable var timer: RestTimer

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "timer")
            Text("Rest")
                .font(.footnote).bold()
            Text(formatted)
                .font(.title3).bold().monospacedDigit()
            Spacer(minLength: 4)
            Button {
                timer.stop()
            } label: {
                Text("Skip")
                    .font(.footnote).bold()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(.regularMaterial)
                .overlay(Capsule().stroke(Color.secondary.opacity(0.25)))
        )
        .padding(.horizontal, 16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, y: 2)
    }

    private var formatted: String {
        let minutes = timer.remaining / 60
        let seconds = timer.remaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
