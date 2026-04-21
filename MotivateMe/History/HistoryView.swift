//
//  HistoryView.swift
//  MotivateMe
//
//  Lists every saved Session, newest first, grouped by day. Morning Light
//  treatment uses a vertical timeline rail with category-tinted dots, a
//  summary strip at the top, a search pill, and category filter chips.
//  Tap a row to expand notes and metrics; tap again to collapse. Tap
//  through to SessionDetailView for the deep dive.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]

    @State private var query: String = ""
    @State private var filter: HistoryFilter = .all
    @State private var expandedSessionId: PersistentIdentifier?

    var body: some View {
        NavigationStack {
            ZStack {
                MMColor.bg.ignoresSafeArea()
                if sessions.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            heroHeader
                            summaryStrip
                            searchField
                            filterChips
                            timeline
                            footerQuote
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                        .padding(.bottom, 32)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Hero header

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            MMEyebrow(text: heroEyebrow)
            Text("History")
                .font(MMFont.largeTitle)
                .foregroundStyle(MMColor.textPrimary)
            Text("Every session you showed up for. Nothing lost.")
                .font(MMFont.subhead)
                .foregroundStyle(MMColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 6)
        .padding(.bottom, 4)
    }

    private var heroEyebrow: String {
        let cal = Calendar.current
        let dates = Set(sessions.map { cal.startOfDay(for: $0.date) })
        guard let earliest = dates.min() else { return "—" }
        let span = max(1, cal.dateComponents([.day], from: earliest, to: cal.startOfDay(for: Date())).day ?? 0) + 1
        return "Last \(min(365, span)) days"
    }

    // MARK: - Filtering

    private var filteredSessions: [Session] {
        sessions.filter { session in
            if !filter.matches(session) { return false }
            if !query.isEmpty {
                let title = SessionPresenter.title(for: session).lowercased()
                let notes = (session.notes ?? "").lowercased()
                let q = query.lowercased()
                if !title.contains(q) && !notes.contains(q) { return false }
            }
            return true
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(MMColor.secondaryTint)
                    .frame(width: 72, height: 72)
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(MMColor.secondary)
            }
            Text("No sessions yet")
                .font(MMFont.title3)
                .foregroundStyle(MMColor.textPrimary)
            Text("Your logged workouts will gather here, day by day.")
                .font(MMFont.subhead)
                .foregroundStyle(MMColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - Summary strip

    private var summaryStrip: some View {
        let stats = SummaryStats.from(sessions: sessions)

        return MMCard(tone: .surface, radius: 22, padding: 14, shadow: .sm) {
            HStack(spacing: 0) {
                summaryStat(value: "\(stats.sessions)", label: "Sessions")
                divider
                summaryStat(value: "\(stats.minutes)", label: "Minutes")
                divider
                summaryStat(value: "\(stats.daysActive)", label: "Days active")
            }
        }
    }

    private func summaryStat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(MMColor.textPrimary)
                .monospacedDigit()
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .tracking(0.6)
                .foregroundStyle(MMColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(MMColor.separator)
            .frame(width: 1, height: 36)
    }

    // MARK: - Search

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(MMColor.textTertiary)
            TextField("Search sessions & notes", text: $query)
                .font(MMFont.callout)
                .foregroundStyle(MMColor.textPrimary)
                .submitLabel(.search)
            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(MMColor.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            Capsule().fill(MMColor.surfaceCard)
        )
        .mmShadow(.xs)
    }

    // MARK: - Filter chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(HistoryFilter.allCases, id: \.self) { f in
                    let selected = f == filter
                    Button {
                        filter = f
                    } label: {
                        Text(f.label)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(selected ? MMColor.onPrimary : MMColor.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selected ? MMColor.primary : Color.clear)
                                    .overlay(
                                        Capsule().strokeBorder(selected ? .clear : MMColor.border, lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - Timeline

    @ViewBuilder
    private var timeline: some View {
        if filteredSessions.isEmpty {
            MMCard(tone: .surface, radius: 22, padding: 28, shadow: .sm) {
                VStack(spacing: 6) {
                    Text("Nothing here yet")
                        .font(MMFont.title3)
                        .foregroundStyle(MMColor.textPrimary)
                    Text("Try a different filter — or go make some history.")
                        .font(MMFont.subhead)
                        .foregroundStyle(MMColor.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
        } else {
            VStack(alignment: .leading, spacing: 18) {
                ForEach(groupedSessions, id: \.key) { group in
                    daySection(label: group.label, sessions: group.sessions)
                }
            }
        }
    }

    private func daySection(label: DayLabel, sessions: [Session]) -> some View {
        let dayMinutes = sessions.reduce(into: 0) { $0 += ($1.durationSeconds ?? 0) / 60 }

        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .lastTextBaseline) {
                Text(label.main)
                    .font(MMFont.headline)
                    .foregroundStyle(MMColor.textPrimary)
                Text(label.sub)
                    .font(MMFont.footnote)
                    .foregroundStyle(MMColor.textTertiary)
                Spacer()
                Text("\(dayMinutes)m · \(sessions.count)")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(MMColor.textSecondary)
            }
            .padding(.horizontal, 4)

            HStack(alignment: .top, spacing: 10) {
                Rectangle()
                    .fill(MMColor.border)
                    .frame(width: 2)
                    .padding(.vertical, 18)
                    .padding(.leading, 7)

                VStack(spacing: 8) {
                    ForEach(sessions) { session in
                        HistoryRow(
                            session: session,
                            isExpanded: expandedSessionId == session.persistentModelID,
                            onToggle: {
                                let id = session.persistentModelID
                                withAnimation(MMMotion.spring(response: 0.32, damping: 0.85)) {
                                    expandedSessionId = expandedSessionId == id ? nil : id
                                }
                            }
                        )
                    }
                }
                .padding(.leading, -16)
            }
        }
    }

    // MARK: - Grouping

    private struct DayGroup {
        let key: Date
        let label: DayLabel
        let sessions: [Session]
    }

    private var groupedSessions: [DayGroup] {
        let calendar = Calendar.current
        var groups: [DayGroup] = []
        for session in filteredSessions {
            let day = calendar.startOfDay(for: session.date)
            if let last = groups.last, last.key == day {
                groups[groups.count - 1] = DayGroup(
                    key: day,
                    label: last.label,
                    sessions: last.sessions + [session]
                )
            } else {
                groups.append(DayGroup(
                    key: day,
                    label: DayLabel.from(day: day),
                    sessions: [session]
                ))
            }
        }
        return groups
    }

    private var footerQuote: some View {
        MMQuoteCard(
            quote: "Every one of these is a vote for the person you're becoming.",
            attribution: nil
        )
        .padding(.top, 6)
    }
}

// MARK: - Filters

private enum HistoryFilter: CaseIterable {
    case all, strength, mobility, rest

    var label: String {
        switch self {
        case .all:      return "All"
        case .strength: return "Strength"
        case .mobility: return "Mobility"
        case .rest:     return "Rest"
        }
    }

    func matches(_ session: Session) -> Bool {
        switch self {
        case .all:
            return true
        case .strength:
            guard session.status != .restDayLogged else { return false }
            let cat = SessionPresenter.category(for: session)
            return cat == .strength
        case .mobility:
            guard session.status != .restDayLogged else { return false }
            let cat = SessionPresenter.category(for: session)
            return cat == .mobility
        case .rest:
            return session.status == .restDayLogged
        }
    }
}

// MARK: - Day label

private struct DayLabel {
    let main: String
    let sub: String

    static func from(day: Date) -> DayLabel {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let days = calendar.dateComponents([.day], from: day, to: today).day ?? 0
        let sub = day.formatted(.dateTime.month(.abbreviated).day())
        switch days {
        case 0: return DayLabel(main: "Today", sub: sub)
        case 1: return DayLabel(main: "Yesterday", sub: sub)
        default: return DayLabel(main: day.formatted(.dateTime.weekday(.wide)), sub: sub)
        }
    }
}

// MARK: - Summary stats

private struct SummaryStats {
    let sessions: Int
    let minutes: Int
    let daysActive: Int

    static func from(sessions: [Session]) -> SummaryStats {
        let workoutSessions = sessions.filter { $0.status != .restDayLogged && $0.status != .upcoming }
        let totalMinutes = workoutSessions.reduce(into: 0) { $0 += ($1.durationSeconds ?? 0) / 60 }
        let calendar = Calendar.current
        let activeDays = Set(workoutSessions.map { calendar.startOfDay(for: $0.date) })
        return SummaryStats(
            sessions: workoutSessions.count,
            minutes: totalMinutes,
            daysActive: activeDays.count
        )
    }
}

// MARK: - History row

private struct HistoryRow: View {
    let session: Session
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        let category = SessionPresenter.category(for: session)
        let tint = category.color

        ZStack(alignment: .topLeading) {
            // Rail dot
            Circle()
                .fill(MMColor.surfaceCard)
                .frame(width: 16, height: 16)
                .overlay(Circle().strokeBorder(tint, lineWidth: 2))
                .overlay(Circle().fill(tint).frame(width: 6, height: 6))
                .offset(x: -1, y: 18)

            Button(action: onToggle) {
                content(tint: tint, category: category)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.leading, 22)
        }
    }

    @ViewBuilder
    private func content(tint: Color, category: SessionCategory) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(tint.opacity(0.16))
                        .frame(width: 36, height: 36)
                    Image(systemName: category.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(tint)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(SessionPresenter.title(for: session))
                            .font(MMFont.callout)
                            .foregroundStyle(MMColor.textPrimary)
                            .lineLimit(1)
                        Spacer(minLength: 6)
                        if let mins = SessionPresenter.minutes(for: session) {
                            Text("\(mins)m")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundStyle(MMColor.textTertiary)
                        }
                    }
                    HStack(spacing: 6) {
                        Text(category.label.uppercased())
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .tracking(0.4)
                            .foregroundStyle(tint)
                        if !session.prExerciseIds.isEmpty {
                            Text("·")
                                .foregroundStyle(MMColor.textTertiary)
                            HStack(spacing: 3) {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 10))
                                Text("\(session.prExerciseIds.count) PR")
                            }
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(MMColor.primary)
                        }
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(MMColor.textTertiary)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .animation(MMMotion.spring(response: 0.32, damping: 0.85), value: isExpanded)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Divider().background(MMColor.border)
                    if let note = session.notes, !note.isEmpty {
                        Text("\u{201C}\(note)\u{201D}")
                            .font(MMFont.quote)
                            .foregroundStyle(MMColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Text("No note this time.")
                            .font(MMFont.footnote)
                            .italic()
                            .foregroundStyle(MMColor.textTertiary)
                    }

                    let metrics = SessionPresenter.metrics(for: session)
                    if !metrics.isEmpty {
                        VStack(spacing: 8) {
                            ForEach(metrics) { metric in
                                metricPill(metric)
                            }
                        }
                    }

                    NavigationLink {
                        SessionDetailView(session: session)
                    } label: {
                        HStack(spacing: 4) {
                            Text("View details")
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .font(MMFont.footnote)
                        .foregroundStyle(MMColor.primary)
                    }
                    .padding(.top, 2)
                }
                .padding(.top, 12)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(MMColor.surfaceCard)
        )
        .mmShadow(.xs)
    }

    private func metricPill(_ metric: SessionPresenter.Metric) -> some View {
        HStack {
            Text(metric.label.uppercased())
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .tracking(0.5)
                .foregroundStyle(MMColor.textTertiary)
            Spacer()
            Text(metric.value)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(MMColor.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(MMColor.surfaceInput)
        )
    }
}

// MARK: - Session presentation helpers

private enum SessionCategory {
    case strength, mobility, rest, other

    var label: String {
        switch self {
        case .strength: return "Strength"
        case .mobility: return "Mobility"
        case .rest:     return "Rest"
        case .other:    return "Session"
        }
    }

    var color: Color {
        switch self {
        case .strength: return MMColor.primary
        case .mobility: return MMColor.secondary
        case .rest:     return MMColor.info
        case .other:    return MMColor.textSecondary
        }
    }

    var icon: String {
        switch self {
        case .strength: return "dumbbell.fill"
        case .mobility: return "leaf.fill"
        case .rest:     return "moon.zzz.fill"
        case .other:    return "figure.walk"
        }
    }
}

private enum SessionPresenter {
    struct Metric: Identifiable {
        let id = UUID()
        let label: String
        let value: String
    }

    static func title(for session: Session) -> String {
        if session.status == .restDayLogged { return "Rest day" }
        if let id = session.workoutTemplateId,
           let template = LibraryStore.shared.workoutTemplate(id: id) {
            return template.name
        }
        return "Workout"
    }

    static func category(for session: Session) -> SessionCategory {
        if session.status == .restDayLogged { return .rest }
        if let id = session.workoutTemplateId,
           let template = LibraryStore.shared.workoutTemplate(id: id) {
            switch template.templateCategory {
            case .mobility:       return .mobility
            case .fullBody, .upper, .lower, .push, .pull, .legs:
                return .strength
            }
        }
        return .other
    }

    static func minutes(for session: Session) -> Int? {
        guard let seconds = session.durationSeconds, seconds > 0 else { return nil }
        return seconds / 60
    }

    static func metrics(for session: Session) -> [Metric] {
        var out: [Metric] = []
        let allSets = session.sessionExercises?.flatMap(\.sets) ?? []
        let completed = allSets.filter(\.completed)
        if !allSets.isEmpty {
            out.append(Metric(label: "Sets", value: "\(completed.count) of \(allSets.count)"))
        }
        let volume = completed.reduce(0.0) { partial, set in
            partial + (set.weight ?? 0) * Double(set.reps ?? 0)
        }
        if volume > 0 {
            let formatted = volume.truncatingRemainder(dividingBy: 1) == 0
                ? String(format: "%.0f", volume)
                : String(format: "%.1f", volume)
            out.append(Metric(label: "Volume", value: formatted))
        }
        if let rating = session.effortRating, let level = EffortLevel(rating: rating) {
            out.append(Metric(label: "Felt", value: level.displayName))
        }
        return out
    }
}
