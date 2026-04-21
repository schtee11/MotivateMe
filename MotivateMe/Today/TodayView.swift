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
    @Environment(\.modelContext) private var modelContext
    @Environment(ErrorPresenter.self) private var errorPresenter
    @Bindable var profile: UserProfile
    @State private var activeWorkoutTemplate: WorkoutTemplate?
    @State private var showingPicker: Bool = false
    @State private var showingLighterPicker: Bool = false
    @State private var showingCheckin: Bool = false

    @Query(sort: \Session.date, order: .reverse) private var allSessions: [Session]
    @Query(sort: \DailyCheckin.date, order: .reverse) private var allCheckins: [DailyCheckin]

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

    private var todaysCheckin: DailyCheckin? {
        let calendar = Calendar.current
        return allCheckins.first { calendar.isDate($0.date, inSameDayAs: Date()) }
    }

    private var todaysReadiness: Int? {
        todaysCheckin?.readinessScore
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    dateHeader
                    checkinBanner
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
                    profile: profile,
                    previousSession: lastSession(for: template)
                )
            }
            .sheet(isPresented: $showingPicker) {
                WorkoutPickerView(profile: profile) { picked in
                    activeWorkoutTemplate = picked
                }
            }
            .sheet(isPresented: $showingLighterPicker) {
                WorkoutPickerView(profile: profile, initialEffortFilter: .easy) { picked in
                    activeWorkoutTemplate = picked
                }
            }
            .sheet(isPresented: $showingCheckin) {
                DailyCheckinSheet()
            }
        }
    }

    @ViewBuilder
    private var checkinBanner: some View {
        if let score = todaysReadiness {
            Button { showingCheckin = true } label: {
                HStack(spacing: 10) {
                    Image(systemName: "sun.max")
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Readiness \(score)/10")
                            .font(.footnote).bold()
                            .foregroundStyle(.primary)
                        Text("Tap to update")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.secondary.opacity(0.08))
                )
            }
            .buttonStyle(.plain)
        } else {
            Button { showingCheckin = true } label: {
                HStack(spacing: 10) {
                    Image(systemName: "sun.max.fill")
                        .foregroundStyle(Color.accentColor)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("How are you feeling today?")
                            .font(.footnote).bold()
                            .foregroundStyle(.primary)
                        Text("Quick morning check-in")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor.opacity(0.1))
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var weekStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .lastTextBaseline) {
                Text("This week")
                    .font(.headline)
                Text(weekSummaryText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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

    // Count of scheduled workout days (non-rest entries) and sessions logged
    // within the current calendar week. "Workout" here excludes pure rest-day
    // logs since they don't count toward the planned-workout tally.
    private var weekSummaryText: String {
        let planned = profile.weeklySchedule.filter { $0.templateCategory != nil }.count
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) else {
            return ""
        }
        let done = allSessions.filter { session in
            guard session.status != .restDayLogged else { return false }
            return weekInterval.contains(session.date)
        }.count
        return planned == 0 ? "" : "· \(done) of \(planned) done"
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
        HStack {
            Text(Date().formatted(.dateTime.weekday(.wide).month().day()))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            streakPill
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var streakPill: some View {
        let streak = StreakCalculator.currentStreak(sessions: allSessions, profile: profile)
        if streak > 0 {
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("\(streak)")
                    .font(.subheadline).bold()
                    .monospacedDigit()
                Text(streak == 1 ? "day" : "days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(Color.orange.opacity(0.12))
            )
        }
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
            Text(completedTitle(status: session.status))
                .font(.title2).bold()
            Text(subtitle(status: session.status, completed: completedCount, total: total))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                if let template = recommendedTemplate {
                    Button {
                        activeWorkoutTemplate = template
                    } label: {
                        Label("Start another", systemImage: "plus.circle")
                            .font(.footnote)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }

                Button {
                    showingPicker = true
                } label: {
                    Label("Pick a workout", systemImage: "list.bullet")
                        .font(.footnote)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.accentColor.opacity(0.12))
        )
    }

    private func completedTitle(status: SessionStatus) -> String {
        switch status {
        case .completed, .partial: return "Nice work"
        case .skipped:             return "Logged — rest up"
        case .restDayLogged:       return "Resting today"
        case .upcoming:            return ""
        }
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
        let isLowReadiness = (todaysReadiness ?? 7) <= 4

        return VStack(alignment: .leading, spacing: 12) {
            Text(category.displayName.uppercased())
                .font(.caption).bold()
                .foregroundStyle(.secondary)

            Text(template.name)
                .font(.title).bold()

            if isLowReadiness {
                HStack(spacing: 8) {
                    Image(systemName: "leaf")
                        .foregroundStyle(.orange)
                    Text("Feeling wiped today? Take it easy.")
                        .font(.footnote)
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.orange.opacity(0.12))
                )
            } else if let summary = template.summary {
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
                Text(isLowReadiness ? "Start anyway" : "Start workout")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 4)

            if isLowReadiness {
                Button {
                    showingLighterPicker = true
                } label: {
                    Label("Try a lighter option", systemImage: "leaf")
                        .font(.footnote)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            Button {
                showingPicker = true
            } label: {
                Label("Swap workout", systemImage: "arrow.left.arrow.right")
                    .font(.footnote)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
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

            Button {
                showingPicker = true
            } label: {
                Label("Pick a workout", systemImage: "list.bullet")
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

            Button {
                logRestDay()
            } label: {
                Label("Log rest day", systemImage: "moon.zzz")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 4)

            Button {
                showingPicker = true
            } label: {
                Label("Pick a workout anyway", systemImage: "list.bullet")
                    .font(.footnote)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.08))
        )
    }

    // Create a zero-exercise Session marking that the user consciously took the
    // day off. Shows up in History and keeps streak logic (future) honest.
    private func logRestDay() {
        let session = Session()
        session.date = Date()
        session.completedAt = Date()
        session.status = .restDayLogged
        modelContext.insert(session)
        do {
            try modelContext.save()
        } catch {
            errorPresenter.present(error, context: "Logging your rest day")
        }
    }
}
