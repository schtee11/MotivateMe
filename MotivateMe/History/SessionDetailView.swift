//
//  SessionDetailView.swift
//  MotivateMe
//
//  Drill-down for a single saved Session. Shows the template name,
//  date/duration header, and every SessionExercise with its SetRecords.
//  Read-only for now — editing past sessions is not an MVP feature.
//

import SwiftUI
import SwiftData

struct SessionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let session: Session

    @State private var showingDeleteConfirmation: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                statCard
                exerciseList
            }
            .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .confirmationDialog(
            "Delete this session?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) { deleteSession() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This can't be undone.")
        }
    }

    private var template: WorkoutTemplate? {
        guard let id = session.workoutTemplateId else { return nil }
        return LibraryStore.shared.workoutTemplate(id: id)
    }

    private var title: String {
        template?.name ?? "Workout"
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(session.date.formatted(.dateTime.weekday(.wide).month().day().year()))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let summary = template?.summary {
                Text(summary)
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var statCard: some View {
        let sets = session.sessionExercises?.flatMap(\.sets) ?? []
        let completed = sets.filter(\.completed).count
        let total = sets.count
        let duration = session.durationSeconds.map(formatDuration) ?? "—"

        return HStack(spacing: 0) {
            statCell(label: "Status", value: statusLabel)
            divider
            statCell(label: "Sets", value: "\(completed)/\(total)")
            divider
            statCell(label: "Time", value: duration)
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.08))
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.2))
            .frame(width: 1, height: 28)
    }

    private func statCell(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var exerciseList: some View {
        let exercises = (session.sessionExercises ?? []).sorted(by: { $0.order < $1.order })
        if exercises.isEmpty {
            Text("No exercises logged.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(exercises) { sessionExercise in
                    ExerciseDetailCard(sessionExercise: sessionExercise)
                }
            }
        }
    }

    private var statusLabel: String {
        switch session.status {
        case .completed:     return "Done"
        case .partial:       return "Partial"
        case .skipped:       return "Skipped"
        case .restDayLogged: return "Rest"
        case .upcoming:      return "Upcoming"
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        if minutes < 1 { return "<1m" }
        if minutes < 60 { return "\(minutes)m" }
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h \(mins)m"
    }

    private func deleteSession() {
        modelContext.delete(session)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Exercise detail card

private struct ExerciseDetailCard: View {
    let sessionExercise: SessionExercise

    private var exercise: Exercise? {
        LibraryStore.shared.exercise(id: sessionExercise.exerciseId)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(exercise?.name ?? "Exercise")
                    .font(.headline)
                Spacer()
                if sessionExercise.skipped {
                    Text("Skipped")
                        .font(.caption).bold()
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill(Color.secondary.opacity(0.15))
                        )
                }
            }

            if !sessionExercise.skipped && !sessionExercise.sets.isEmpty {
                VStack(spacing: 4) {
                    ForEach(sessionExercise.sets.sorted(by: { $0.setNumber < $1.setNumber }), id: \.setNumber) { set in
                        SetDetailRow(set: set)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.08))
        )
        .opacity(sessionExercise.skipped ? 0.6 : 1)
    }
}

private struct SetDetailRow: View {
    let set: SetRecord

    var body: some View {
        HStack(spacing: 10) {
            Text("Set \(set.setNumber)")
                .font(.caption).bold()
                .foregroundStyle(.secondary)
                .frame(width: 48, alignment: .leading)

            Text(countText)
                .font(.subheadline)
                .monospacedDigit()

            Spacer()

            if let weight = set.weight, weight > 0 {
                Text(weightText(weight))
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }

            Image(systemName: set.completed ? "checkmark.circle.fill" : "circle")
                .font(.footnote)
                .foregroundStyle(set.completed ? Color.accentColor : Color.secondary)
        }
        .padding(.vertical, 2)
    }

    private var countText: String {
        if let reps = set.reps { return "\(reps) reps" }
        if let seconds = set.durationSeconds { return "\(seconds) sec" }
        return "—"
    }

    private func weightText(_ weight: Double) -> String {
        let formatted = weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", weight)
            : String(format: "%.1f", weight)
        return formatted
    }
}
