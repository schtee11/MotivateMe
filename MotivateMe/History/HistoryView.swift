//
//  HistoryView.swift
//  MotivateMe
//
//  Lists every saved Session, newest first, grouped by month. Tapping a
//  row drills into SessionDetailView. Empty state when the user hasn't
//  logged anything yet.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    emptyState
                } else {
                    sessionList
                }
            }
            .navigationTitle("History")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("No sessions yet")
                .font(.headline)
            Text("Your logged workouts will show up here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var sessionList: some View {
        List {
            ForEach(groupedSessions, id: \.key) { group in
                Section(group.key) {
                    ForEach(group.value) { session in
                        NavigationLink {
                            SessionDetailView(session: session)
                        } label: {
                            SessionRow(session: session)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // Group by "Month Year" (e.g. "April 2026"), preserving reverse-chronological
    // order since `sessions` is already sorted. Uses an ordered array of tuples
    // rather than a dictionary so rendering order is deterministic.
    private var groupedSessions: [(key: String, value: [Session])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"

        var groups: [(String, [Session])] = []
        for session in sessions {
            let key = formatter.string(from: session.date)
            if let lastIndex = groups.indices.last, groups[lastIndex].0 == key {
                groups[lastIndex].1.append(session)
            } else {
                groups.append((key, [session]))
            }
        }
        return groups
    }
}

// MARK: - Row

private struct SessionRow: View {
    let session: Session

    var body: some View {
        HStack(spacing: 12) {
            statusIcon
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline).bold()
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(session.date.formatted(.dateTime.weekday(.abbreviated).day()))
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    private var title: String {
        if let id = session.workoutTemplateId,
           let template = LibraryStore.shared.workoutTemplate(id: id) {
            return template.name
        }
        return "Workout"
    }

    private var subtitle: String {
        let sets = session.sessionExercises?.flatMap(\.sets) ?? []
        let completed = sets.filter(\.completed).count
        let total = sets.count

        switch session.status {
        case .completed:     return "Completed · \(total) sets"
        case .partial:       return "Partial · \(completed)/\(total) sets"
        case .skipped:       return "Skipped"
        case .restDayLogged: return "Rest day"
        case .upcoming:      return "Upcoming"
        }
    }

    @ViewBuilder
    private var statusIcon: some View {
        let (symbol, color) = iconSpec
        Image(systemName: symbol)
            .font(.title3)
            .foregroundStyle(color)
            .frame(width: 28)
    }

    private var iconSpec: (String, Color) {
        switch session.status {
        case .completed:     return ("checkmark.circle.fill", .accentColor)
        case .partial:       return ("circle.lefthalf.filled", .accentColor)
        case .skipped:       return ("xmark.circle", .secondary)
        case .restDayLogged: return ("moon.zzz", .secondary)
        case .upcoming:      return ("circle.dotted", .secondary)
        }
    }
}
