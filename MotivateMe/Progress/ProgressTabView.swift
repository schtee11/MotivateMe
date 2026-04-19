//
//  ProgressTabView.swift
//  MotivateMe
//
//  4th tab. Shows the user evidence that the work is paying off.
//  Morning Light styling: a streak hero, a 12-week heatmap of session
//  rhythm, the last six weeks as warm peach bars, and a celebrated PR
//  card. Read-only — drives motivation, not action.
//
//  Named *TabView to avoid collision with SwiftUI's built-in ProgressView.
//

import SwiftUI
import SwiftData

struct ProgressTabView: View {
    @Bindable var profile: UserProfile
    @Query(sort: \Session.date, order: .reverse) private var allSessions: [Session]

    var body: some View {
        NavigationStack {
            ZStack {
                MMColor.bg.ignoresSafeArea()
                if hasNoData {
                    emptyState
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            headlineRow
                            heroCard
                            weeklyBarsCard
                            heatmapCard
                            recentPRsCard
                            weeklyReflection
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 6)
                        .padding(.bottom, 32)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Progress")
        }
    }

    private var hasNoData: Bool {
        allSessions.allSatisfy { $0.status == .restDayLogged || $0.status == .upcoming }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(MMColor.primaryTint)
                    .frame(width: 72, height: 72)
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(MMColor.primary)
            }
            Text("Nothing to chart yet")
                .font(MMFont.title3)
                .foregroundStyle(MMColor.textPrimary)
            Text("A few sessions and your rhythm will start to show up here.")
                .font(MMFont.subhead)
                .foregroundStyle(MMColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - Stats

    private var streak: Int {
        StreakCalculator.currentStreak(sessions: allSessions, profile: profile)
    }

    private var monthCount: Int {
        ProgressStats.sessionsThisMonth(allSessions)
    }

    private var weekBuckets: [ProgressStats.WeekBucket] {
        ProgressStats.weeklyBuckets(allSessions)
    }

    private var recentPRs: [ProgressStats.RecentPR] {
        ProgressStats.recentPRs(allSessions)
    }

    // MARK: - Sections

    private var headlineRow: some View {
        HStack(spacing: 12) {
            headlineStat(
                value: "\(streak)",
                label: streak == 1 ? "day streak" : "day streak",
                icon: "flame.fill",
                tone: MMColor.primary,
                background: MMColor.primaryTint
            )
            headlineStat(
                value: "\(monthCount)",
                label: "this month",
                icon: "checkmark.seal.fill",
                tone: MMColor.secondary,
                background: MMColor.secondaryTint
            )
        }
    }

    private func headlineStat(value: String, label: String, icon: String, tone: Color, background: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(tone)
            Text(value)
                .font(MMFont.title1)
                .foregroundStyle(MMColor.textPrimary)
                .monospacedDigit()
            Text(label)
                .font(MMFont.footnote)
                .foregroundStyle(MMColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous).fill(background)
        )
    }

    @ViewBuilder
    private var heroCard: some View {
        if streak > 0 {
            StreakHero(
                days: streak,
                message: "You've shown up \(streak) day\(streak == 1 ? "" : "s") in a row. Quietly impressive."
            )
        }
    }

    private var weeklyBarsCard: some View {
        MMCard(tone: .surface, radius: 22, padding: 18, shadow: .sm) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .lastTextBaseline) {
                    Text("Last 6 weeks")
                        .font(MMFont.headline)
                        .foregroundStyle(MMColor.textPrimary)
                    Spacer()
                    Text(trendText)
                        .font(MMFont.footnote)
                        .foregroundStyle(MMColor.textSecondary)
                }

                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(weekBuckets) { bucket in
                        VStack(spacing: 8) {
                            GeometryReader { geo in
                                let max = max(1, weekBuckets.map(\.count).max() ?? 1)
                                let h = max == 0 ? 0 : CGFloat(bucket.count) / CGFloat(max) * geo.size.height
                                ZStack(alignment: .bottom) {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(isCurrent(bucket) ? MMColor.primary : MMColor.primaryMuted)
                                        .frame(height: max(6, h))
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                            }
                            .frame(height: 110)

                            Text(weekLabel(bucket.weekStart))
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(MMColor.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    private func isCurrent(_ bucket: ProgressStats.WeekBucket) -> Bool {
        let cal = Calendar.current
        return cal.isDate(bucket.weekStart, equalTo: Date(), toGranularity: .weekOfYear)
    }

    private func weekLabel(_ date: Date) -> String {
        date.formatted(.dateTime.month(.abbreviated).day())
    }

    private var trendText: String {
        let counts = weekBuckets.map(\.count)
        guard counts.count >= 2 else { return "" }
        let recent = counts.last ?? 0
        let prior = counts[counts.count - 2]
        if recent > prior { return "Trending up, gently." }
        if recent < prior { return "Soft week — that's fine." }
        return "Holding steady."
    }

    private var heatmapCard: some View {
        MMCard(tone: .surface, radius: 22, padding: 18, shadow: .sm) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Your rhythm")
                        .font(MMFont.headline)
                        .foregroundStyle(MMColor.textPrimary)
                    Spacer()
                    Text("84 days")
                        .font(MMFont.caption1)
                        .foregroundStyle(MMColor.textTertiary)
                }
                MMHeatmap(values: heatmapValues)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    /// 12 weeks × 7 days, column-major: col 0 = oldest week, row 0 = Mon.
    private var heatmapValues: [Double] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        // Start of the 12-week-ago Monday
        guard let earliest = cal.date(byAdding: .day, value: -7 * 12 + 1, to: today) else {
            return Array(repeating: 0, count: 84)
        }

        // Bucket sessions into a [date: hadWorkout?] map
        var byDay: [Date: Bool] = [:]
        for session in allSessions where session.status != .restDayLogged && session.status != .upcoming {
            byDay[cal.startOfDay(for: session.date)] = true
        }

        var values: [Double] = []
        values.reserveCapacity(84)
        for col in 0..<12 {
            for row in 0..<7 {
                let dayOffset = col * 7 + row
                guard let day = cal.date(byAdding: .day, value: dayOffset, to: earliest) else {
                    values.append(0); continue
                }
                values.append(byDay[day] == true ? 1.0 : 0.0)
            }
        }
        return values
    }

    @ViewBuilder
    private var recentPRsCard: some View {
        if recentPRs.isEmpty {
            EmptyView()
        } else {
            MMCard(tone: .primaryTint, radius: 22, padding: 18, shadow: .sm) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(MMColor.primary)
                        Text("Recent PRs")
                            .font(MMFont.headline)
                            .foregroundStyle(MMColor.textPrimary)
                    }
                    VStack(spacing: 10) {
                        ForEach(recentPRs) { pr in
                            prRow(pr)
                        }
                    }
                }
            }
        }
    }

    private func prRow(_ pr: ProgressStats.RecentPR) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(pr.exerciseName)
                    .font(MMFont.subhead)
                    .foregroundStyle(MMColor.textPrimary)
                Text(pr.date.formatted(.dateTime.month(.abbreviated).day()))
                    .font(MMFont.caption1)
                    .foregroundStyle(MMColor.textSecondary)
            }
            Spacer()
            Text(prValueText(pr))
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(MMColor.primary)
                .monospacedDigit()
        }
    }

    private func prValueText(_ pr: ProgressStats.RecentPR) -> String {
        let unit = profile.preferredUnit == .pounds ? "lb" : "kg"
        if let weight = pr.weight {
            let weightStr = weight.truncatingRemainder(dividingBy: 1) == 0
                ? String(format: "%.0f", weight)
                : String(format: "%.1f", weight)
            if let reps = pr.reps {
                return "\(weightStr) \(unit) × \(reps)"
            }
            return "\(weightStr) \(unit)"
        }
        if let reps = pr.reps {
            return "\(reps) reps"
        }
        return "—"
    }

    private var weeklyReflection: some View {
        MMQuoteCard(
            quote: "Progress is quiet. Trust the rhythm.",
            attribution: "A note for the long run"
        )
    }
}
