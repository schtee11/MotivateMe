//
//  TodayView.swift
//  MotivateMe
//
//  Post-onboarding landing screen, dressed in the "Morning Light" design.
//  Reads the user's weekly schedule, looks up today's category, and
//  recommends a matching template from the library. Renders one of four
//  states: completed, rest day, workout day with template, or no-match.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ErrorPresenter.self) private var errorPresenter
    @Bindable var profile: UserProfile

    @State private var activeWorkoutTemplate: WorkoutTemplate?
    @State private var resumeSnapshot: WorkoutDraftSnapshot?
    @State private var showingResumePrompt: Bool = false
    @State private var showingPicker: Bool = false
    @State private var showingLighterPicker: Bool = false
    @State private var showingCheckin: Bool = false

    @AppStorage("mm.userName") private var userName: String = ""

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

    private var todaysSession: Session? {
        let calendar = Calendar.current
        return allSessions.first { calendar.isDate($0.date, inSameDayAs: Date()) }
    }

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

    private var todaysReadiness: Int? { todaysCheckin?.readinessScore }

    private var currentStreak: Int {
        StreakCalculator.currentStreak(sessions: allSessions, profile: profile)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let base: String
        switch hour {
        case ..<12: base = "Good morning"
        case ..<18: base = "Good afternoon"
        default:    base = "Good evening"
        }
        let trimmed = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? base : "\(base), \(trimmed)"
    }

    private var userInitials: String? {
        let trimmed = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let parts = trimmed.split(separator: " ").prefix(2)
        let letters = parts.compactMap(\.first).map(String.init).joined()
        return letters.isEmpty ? nil : letters.uppercased()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    checkinBanner
                    if currentStreak > 0 {
                        StreakHero(days: currentStreak, message: streakMessage(currentStreak))
                    }
                    todaysFocusSection
                    weeklyRhythmCard
                    encouragementCard
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .scrollContentBackground(.hidden)
            .background(MMColor.bg.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SettingsView(profile: profile)
                    } label: {
                        ZStack {
                            Circle()
                                .fill(MMColor.secondaryMuted)
                                .frame(width: 34, height: 34)
                            if let initials = userInitials {
                                Text(initials)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(MMColor.secondary)
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(MMColor.secondary)
                            }
                        }
                    }
                    .accessibilityLabel("Settings")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCheckin = true
                    } label: {
                        Image(systemName: "bell")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(MMColor.textSecondary)
                    }
                    .accessibilityLabel("Check-in")
                }
            }
            .fullScreenCover(item: $activeWorkoutTemplate) { template in
                ActiveWorkoutView(
                    template: template,
                    profile: profile,
                    previousSession: lastSession(for: template),
                    resumingFrom: resumeSnapshot?.templateId == template.id ? resumeSnapshot : nil
                )
                .onDisappear { resumeSnapshot = nil }
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
            .alert("Resume workout?", isPresented: $showingResumePrompt, presenting: resumeSnapshot) { snapshot in
                Button("Resume") {
                    if let template = LibraryStore.shared.workoutTemplate(id: snapshot.templateId) {
                        activeWorkoutTemplate = template
                    } else {
                        WorkoutDraftStore.clear()
                        resumeSnapshot = nil
                    }
                }
                Button("Discard", role: .destructive) {
                    WorkoutDraftStore.clear()
                    resumeSnapshot = nil
                }
            } message: { snapshot in
                let name = LibraryStore.shared.workoutTemplate(id: snapshot.templateId)?.name ?? "your workout"
                Text("You left \(name) in progress. Pick up where you left off?")
            }
            .task { checkForResumableWorkout() }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(Date().formatted(.dateTime.weekday(.wide).month().day()))
                .font(MMFont.footnote)
                .foregroundStyle(MMColor.textSecondary)
            Text(greeting)
                .font(MMFont.largeTitle)
                .foregroundStyle(MMColor.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }

    // MARK: - Check-in banner


    @ViewBuilder
    private var checkinBanner: some View {
        if let score = todaysReadiness {
            MMInlineBanner(
                icon: "sun.max.fill",
                title: "Readiness \(score) of 10",
                subtitle: "We tuned today to match",
                tone: .secondaryTint,
                iconColor: MMColor.secondary,
                action: { showingCheckin = true }
            )
        } else {
            MMInlineBanner(
                icon: "sun.max",
                title: "How are you today?",
                subtitle: "A quick morning check-in · under a minute",
                tone: .primaryTint,
                iconColor: MMColor.primary,
                action: { showingCheckin = true }
            )
        }
    }

    // MARK: - Today's focus (workout / rest / completed)

    private var todaysFocusSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Today's focus")
                    .font(MMFont.title3)
                    .foregroundStyle(MMColor.textPrimary)
                Spacer()
                Text(focusEyebrow)
                    .font(MMFont.footnote)
                    .foregroundStyle(MMColor.textSecondary)
            }
            .padding(.horizontal, 4)

            focusCard
        }
    }

    private var focusEyebrow: String {
        if todaysSession != nil { return "Done" }
        if let category = todayEntry?.templateCategory { return category.displayName }
        return "Rest day"
    }

    @ViewBuilder
    private var focusCard: some View {
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

        return MMCard(tone: .secondaryTint, radius: 28, padding: 20) {
            VStack(alignment: .leading, spacing: 10) {
                MMEyebrow(text: "Done for today", color: MMColor.secondary)
                Text(completedTitle(status: session.status))
                    .font(MMFont.title1)
                    .foregroundStyle(MMColor.textPrimary)
                Text(subtitle(status: session.status, completed: completedCount, total: total))
                    .font(MMFont.subhead)
                    .foregroundStyle(MMColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    if let template = recommendedTemplate {
                        MMPillButton(
                            variant: .secondary, size: .sm,
                            icon: "plus", fullWidth: false,
                            title: "Start another"
                        ) { activeWorkoutTemplate = template }
                    }
                    MMPillButton(
                        variant: .ghost, size: .sm,
                        icon: "list.bullet", fullWidth: false,
                        title: "Pick one"
                    ) { showingPicker = true }
                }
                .padding(.top, 4)
            }
        }
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

        return MMCard(tone: .surface, radius: 28, padding: 22, shadow: .md) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [MMColor.primary.opacity(0.18), .clear],
                            center: .center, startRadius: 4, endRadius: 110
                        )
                    )
                    .frame(width: 170, height: 170)
                    .offset(x: 60, y: -70)
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 10) {
                    MMEyebrow(text: category.displayName)

                    Text(template.name)
                        .font(MMFont.title1)
                        .foregroundStyle(MMColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    if isLowReadiness {
                        HStack(spacing: 8) {
                            Image(systemName: "leaf.fill")
                                .foregroundStyle(MMColor.secondary)
                            Text("Feeling wiped today? Take it easy.")
                                .font(MMFont.footnote)
                                .foregroundStyle(MMColor.textPrimary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(MMColor.secondaryTint)
                        )
                    } else if let summary = template.summary {
                        Text(summary)
                            .font(MMFont.subhead)
                            .foregroundStyle(MMColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    HStack(spacing: 18) {
                        Label("\(template.targetDurationMinutes) min", systemImage: "clock")
                        Label("\(template.exerciseSlots.count) exercises", systemImage: "list.bullet")
                    }
                    .font(MMFont.footnote)
                    .foregroundStyle(MMColor.textSecondary)

                    MMPillButton(
                        variant: .primary,
                        icon: "play.fill",
                        title: isLowReadiness ? "Start anyway" : "Start session"
                    ) {
                        activeWorkoutTemplate = template
                    }
                    .padding(.top, 6)

                    if isLowReadiness {
                        MMPillButton(
                            variant: .secondary, size: .md,
                            icon: "leaf",
                            title: "Try a lighter option"
                        ) { showingLighterPicker = true }
                    }

                    MMPillButton(
                        variant: .ghost, size: .md,
                        icon: "arrow.left.arrow.right",
                        title: "Swap workout"
                    ) { showingPicker = true }
                }
            }
        }
    }

    private func noMatchCard(category: TemplateCategory) -> some View {
        MMCard(tone: .surface, radius: 28, padding: 22, shadow: .sm) {
            VStack(alignment: .leading, spacing: 10) {
                MMEyebrow(text: category.displayName)
                Text("No matching workout")
                    .font(MMFont.title1)
                    .foregroundStyle(MMColor.textPrimary)
                Text("We couldn't find a \(category.displayName.lowercased()) template that fits your equipment. Update equipment in Settings or pick something else.")
                    .font(MMFont.subhead)
                    .foregroundStyle(MMColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                MMPillButton(
                    variant: .primary,
                    icon: "list.bullet",
                    title: "Pick a workout"
                ) { showingPicker = true }
                .padding(.top, 6)
            }
        }
    }

    private var restDayCard: some View {
        MMCard(tone: .secondaryTint, radius: 28, padding: 22, shadow: .sm) {
            VStack(alignment: .leading, spacing: 10) {
                MMEyebrow(text: "Rest day", color: MMColor.secondary)
                Text("Take it easy today")
                    .font(MMFont.title1)
                    .foregroundStyle(MMColor.textPrimary)
                Text("Rest is when the body adapts. Hydrate, sleep well, maybe a walk.")
                    .font(MMFont.subhead)
                    .foregroundStyle(MMColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                MMPillButton(
                    variant: .primary,
                    icon: "moon.zzz.fill",
                    title: "Log rest day"
                ) { logRestDay() }
                .padding(.top, 6)

                MMPillButton(
                    variant: .ghost, size: .md,
                    icon: "list.bullet",
                    title: "Pick a workout anyway"
                ) { showingPicker = true }
            }
        }
    }

    // MARK: - Streak message

    private func streakMessage(_ days: Int) -> String {
        switch days {
        case 1:    return "One day in. The hardest one is behind you."
        case 2...4:  return "You've shown up \(days) days in a row. Keep going gently."
        case 5...13: return "\(days) days strong. Trust the rhythm."
        default:    return "\(days) days. Proud of you."
        }
    }

    // MARK: - Weekly rhythm card

    private var weeklyRhythmCard: some View {
        MMCard(tone: .surface, radius: 22, padding: 18, shadow: .sm) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    Text("This week")
                        .font(MMFont.headline)
                        .foregroundStyle(MMColor.textPrimary)
                    if !weekSummaryText.isEmpty {
                        Text(weekSummaryText)
                            .font(MMFont.footnote)
                            .foregroundStyle(MMColor.textSecondary)
                    }
                    Spacer()
                    NavigationLink {
                        EditScheduleView(profile: profile)
                    } label: {
                        Text("Edit")
                            .font(MMFont.footnote)
                            .foregroundStyle(MMColor.primary)
                    }
                }

                HStack(spacing: 6) {
                    ForEach(Weekday.allCases, id: \.self) { weekday in
                        weekdayPill(weekday)
                    }
                }
            }
        }
    }

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
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(MMColor.textTertiary)
            Text(letter)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .frame(width: 30, height: 30)
                .background(
                    Circle().fill(
                        category == nil
                            ? MMColor.surfaceInput
                            : MMColor.primaryMuted
                    )
                )
                .foregroundStyle(category == nil ? MMColor.textTertiary : MMColor.primary)
                .overlay(
                    Circle().strokeBorder(isToday ? MMColor.primary : .clear, lineWidth: 2)
                )
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Encouragement quote

    private var encouragementCard: some View {
        MMQuoteCard(
            quote: encouragementQuote,
            attribution: "Weekly reflection · Sunday"
        )
    }

    private var encouragementQuote: String {
        // Rotate gently — same quote shows for the day so it doesn't flicker.
        let lines = [
            "Small, steady beats loud and sporadic.",
            "You don't have to feel like it. You just have to start.",
            "Rest is part of training, not a break from it.",
            "Showing up is most of it.",
            "Progress is quiet. Trust the rhythm.",
        ]
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return lines[dayOfYear % lines.count]
    }

    // MARK: - Actions

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

    private func checkForResumableWorkout() {
        guard activeWorkoutTemplate == nil, resumeSnapshot == nil else { return }
        guard let snapshot = WorkoutDraftStore.load() else { return }
        resumeSnapshot = snapshot
        showingResumePrompt = true
    }
}
