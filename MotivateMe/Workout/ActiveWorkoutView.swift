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

    @State private var draft: WorkoutDraft
    @State private var showingDiscardConfirmation: Bool = false
    let weightUnit: Unit

    init(template: WorkoutTemplate, weightUnit: Unit, previousSession: Session? = nil) {
        _draft = State(initialValue: WorkoutDraft(template: template, previousSession: previousSession))
        self.weightUnit = weightUnit
    }

    var body: some View {
        // Inline @Bindable shadow: @State owns the @Observable instance,
        // but property-level bindings ($draft.exerciseDrafts[i]) only
        // project through a @Bindable reference.
        @Bindable var draft = draft

        return NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    ForEach(draft.exerciseDrafts.indices, id: \.self) { index in
                        ExerciseCard(
                            draft: $draft.exerciseDrafts[index],
                            weightUnit: weightUnit
                        )
                    }

                    finishButton
                        .padding(.top, 8)
                }
                .padding()
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
                Button("Discard", role: .destructive) { dismiss() }
                Button("Keep going", role: .cancel) {}
            } message: {
                Text("Nothing will be saved.")
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
        }
    }

    private var finishButton: some View {
        Button {
            draft.save(to: modelContext)
            dismiss()
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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(draft.exercise?.name ?? "Exercise")
                        .font(.headline)
                    Text(draft.targetDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(draft.skipped ? "Unskip" : "Skip") {
                    draft.skipped.toggle()
                }
                .font(.footnote)
                .buttonStyle(.bordered)
                .controlSize(.small)
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
                            weightUnit: weightUnit
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.08))
        )
        .opacity(draft.skipped ? 0.5 : 1)
    }
}

// MARK: - Set row

private struct SetRow: View {
    @Binding var set: SetDraft
    let targetType: SlotTargetType
    let weightUnit: Unit

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
                set.completed.toggle()
            } label: {
                Image(systemName: set.completed ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(set.completed ? Color.accentColor : Color.secondary)
            }
            .buttonStyle(.plain)
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
