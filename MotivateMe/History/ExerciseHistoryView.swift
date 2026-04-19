//
//  ExerciseHistoryView.swift
//  MotivateMe
//
//  Sheet drilldown for one exercise's recent appearances. Triggered from
//  the active workout (tap the exercise name → "what did I do last time?")
//  and from session detail (review past performance for context).
//
//  Read-only — pulls completed SessionExercise rows for this exerciseId
//  and renders set-by-set lines per session.
//

import SwiftUI
import SwiftData

struct ExerciseHistoryView: View {
    let exerciseId: UUID

    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Session.date, order: .reverse) private var allSessions: [Session]

    private var exercise: Exercise? {
        LibraryStore.shared.exercise(id: exerciseId)
    }

    // Up to 10 most recent sessions that included this exercise (and
    // actually logged at least one set — skipped instances aren't useful
    // here).
    private var rows: [(session: Session, sessionExercise: SessionExercise)] {
        var collected: [(Session, SessionExercise)] = []
        for session in allSessions {
            for exercise in session.sessionExercises ?? [] where exercise.exerciseId == exerciseId {
                guard !exercise.skipped, !exercise.sets.isEmpty else { continue }
                collected.append((session, exercise))
                if collected.count >= 10 { return collected }
            }
        }
        return collected
    }

    var body: some View {
        NavigationStack {
            Group {
                if rows.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle(exercise?.name ?? "History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var list: some View {
        List {
            ForEach(rows, id: \.session.id) { row in
                Section {
                    ForEach(row.sessionExercise.sets.sorted(by: { $0.setNumber < $1.setNumber }), id: \.setNumber) { set in
                        setLine(set)
                    }
                } header: {
                    HStack {
                        Text(row.session.date.formatted(.dateTime.weekday(.abbreviated).month().day()))
                            .font(.caption).bold()
                        Spacer()
                        if row.session.prExerciseIds.contains(exerciseId) {
                            Label("PR", systemImage: "trophy.fill")
                                .font(.caption2).bold()
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func setLine(_ set: SetRecord) -> some View {
        HStack(spacing: 12) {
            Text("Set \(set.setNumber)")
                .font(.caption).bold()
                .foregroundStyle(.secondary)
                .frame(width: 48, alignment: .leading)

            Text(countText(set))
                .font(.subheadline)
                .monospacedDigit()

            Spacer()

            if let weight = set.weight, weight > 0 {
                Text(weightText(weight))
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("No history yet")
                .font(.headline)
            Text("Once you log this exercise, your past sets will show up here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func countText(_ set: SetRecord) -> String {
        if let reps = set.reps { return "\(reps) reps" }
        if let seconds = set.durationSeconds { return "\(seconds) sec" }
        return "—"
    }

    private func weightText(_ weight: Double) -> String {
        weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", weight)
            : String(format: "%.1f", weight)
    }
}
