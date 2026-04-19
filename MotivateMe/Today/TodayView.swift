//
//  TodayView.swift
//  MotivateMe
//
//  Post-onboarding landing screen. Reads the user's weekly schedule,
//  looks up today's category, and recommends a matching template from
//  the library. Renders one of four states:
//  - Session already logged today → completed card (no Start button)
//  - Rest day → rest card
//  - Workout day with matching template → workout card with Start
//  - Workout day, no matching template → no-match card
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Bindable var profile: UserProfile
    @State private var activeWorkoutTemplate: WorkoutTemplate?

    @Query(sort: \Session.date, order: .reverse) private var allSessions: [Session]

    private var todayWeekday: Weekday { Weekday.from(date: Date()) }

    private var todayEntry: ScheduleEntry? {
        profile.weeklySchedule.first { $0.weekday == todayWeekday }
    }

    private var recommendedTemplate: WorkoutTemplate? {
        guard let category = todayEntry?.templateCategory else { return nil }
        return TemplateRecommender.recommend(category: category, for: profile)
    }

    // Treat any saved session whose date falls on today as "done for today".
    // Checking the first (most recent) is enough because the query is sorted.
    private var todaysSession: Session? {
        let calendar = Calendar.current
        return allSessions.first { session in
            calendar.isDate(session.date, inSameDayAs: Date())
        }
    }

    // Most recent session logged for this template, excluding today's in-progress
    // one. Used to pre-fill weights so users don't have to re-enter them.
    private func lastSession(for template: WorkoutTemplate) -> Session? {
        let calendar = Calendar.current
        return allSessions.first { session in
            session.workoutTemplateId == template.id
                && !calendar.isDate(session.date, inSameDayAs: Date())
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    dateHeader
                    todayCard
                    weekStrip
                }
                .padding()
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        EditScheduleView(profile: profile)
                    } label: {
                        Image(systemName: "calendar")
                    }
                }
            }
            .fullScreenCover(item: $activeWorkoutTemplate) { template in
                ActiveWorkoutView(
                    template: template,
                    weightUnit: profile.preferredUnit,
                    previousSession: lastSession(for: template)
                )
            }
        }
    }

    private var weekStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("This week")
                    .font(.headline)
                Spacer()
                NavigationLink("Edit") {
                    EditScheduleView(profile: profile)
                }
                .font(.footnote)
            }

            HStack(spacing: 6) {
                ForEach(Weekday.allCases, id: \.self) { weekday in
                    weekdayPill(weekday)
                }
            }
        }
    }

    private func weekdayPill(_ weekday: Weekday) -> some View {
        let entry = profile.weeklySchedule.first { $0.weekday == weekday }
        let isToday = weekday == todayWeekday
        let category = entry?.templateCategory
        let letter = category?.displayName.prefix(1).uppercased() ?? "·"

        return VStack(spacing: 4) {
            Text(weekday.shortName.prefix(1))
                .font(.caption2).bold()
                .foregroundStyle(.secondary)
            Text(letter)
                .font(.caption).bold()
                .frame(width: 28, height: 28)
                .background(
                    Circle().fill(
                        category == nil
                            ? Color.secondary.opacity(0.15)
                            : Color.accentColor.opacity(0.2)
                    )
                )
                .foregroundStyle(category == nil ? .secondary : .primary)
                .overlay(
                    Circle().stroke(
                        isToday ? Color.accentColor : .clear,
                        lineWidth: 2
                    )
                )
        }
        .frame(maxWidth: .infinity)
    }

    private var dateHeader: some View {
        Text(Date().formatted(.dateTime.weekday(.wide).month().day()))
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var todayCard: some View {
        if let session = todaysSession {
            completedCard(session: session)
        } else if let category = todayEntry?.templateCategory {
            if let template = recommendedTemplate {
                workoutCard(template: template, category: category)
            } else {
                noMatchCard(category: category)
            }
        } else {
            restDayCard
        }
    }

    private func completedCard(session: Session) -> some View {
        let allSets = session.sessionExercises?.flatMap { $0.sets } ?? []
        let completedCount = allSets.filter(\.completed).count
        let total = allSets.count

        return VStack(alignment: .leading, spacing: 8) {
            Text("DONE FOR TODAY")
                .font(.caption).bold()
                .foregroundStyle(.secondary)
            Text(session.status == .skipped ? "Logged — rest up" : "Nice work")
                .font(.title2).bold()
            Text(subtitle(status: session.status, completed: completedCount, total: total))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let template = recommendedTemplate {
                Button {
                    activeWorkoutTemplate = template
                } label: {
                    Label("Start another workout", systemImage: "plus.circle")
                        .font(.footnote)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.accentColor.opacity(0.12))
        )
    }

    private func subtitle(status: SessionStatus, completed: Int, total: Int) -> String {
        switch status {
        case .completed:     return "All \(total) sets logged. See you tomorrow."
        case .partial:       return "\(completed) of \(total) sets logged. Good enough is good."
        case .skipped:       return "No sets logged today — that's okay."
        case .restDayLogged: return "Rest day logged."
        case .upcoming:      return ""
        }
    }

    private func workoutCard(template: WorkoutTemplate, category: TemplateCategory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.displayName.uppercased())
                .font(.caption).bold()
                .foregroundStyle(.secondary)

            Text(template.name)
                .font(.title).bold()

            if let summary = template.summary {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                Label("\(template.targetDurationMinutes) min", systemImage: "clock")
                Label("\(template.exerciseSlots.count) exercises", systemImage: "list.bullet")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)

            Button {
                activeWorkoutTemplate = template
            } label: {
                Text("Start workout")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.08))
        )
    }

    private func noMatchCard(category: TemplateCategory) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.displayName.uppercased())
                .font(.caption).bold()
                .foregroundStyle(.secondary)
            Text("No matching workout")
                .font(.title2).bold()
            Text("We couldn't find a \(category.displayName.lowercased()) template that fits your equipment. Update your equipment list or adjust the schedule.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.08))
        )
    }

    private var restDayCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("REST DAY")
                .font(.caption).bold()
                .foregroundStyle(.secondary)
            Text("Take it easy today")
                .font(.title2).bold()
            Text("Rest is when your body adapts. Hydrate, sleep well, maybe a walk.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.08))
        )
    }
}
