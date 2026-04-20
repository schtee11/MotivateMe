//
//  ProgressTabView.swift
//  MotivateMe
//
//  Morning Light Progress tab — adapted from the design's ProgressScreen.
//  Header with eyebrow + large title, range segmented control, two
//  headline stat tiles (streak / readiness), workout-volume trend line,
//  PR celebration card, weekly serif summary, body measurements, and a
//  readiness heatmap. Read-only — drives motivation, not action.
//

import SwiftUI
import SwiftData

struct ProgressTabView: View {
    @Bindable var profile: UserProfile
    @Query(sort: \Session.date, order: .reverse) private var allSessions: [Session]
    @Query(sort: \DailyCheckin.date, order: .reverse) private var allCheckins: [DailyCheckin]
    @Query(sort: \BodyMeasurement.date, order: .reverse) private var allMeasurements: [BodyMeasurement]

    @State private var range: ProgressStats.Range = .month

    var body: some View {
        NavigationStack {
            ZStack {
                MMColor.bg.ignoresSafeArea()
                if hasNoData {
                    emptyState
                } else {
                    content
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var hasNoData: Bool {
        allSessions.allSatisfy { $0.status == .restDayLogged || $0.status == .upcoming }
            && allCheckins.isEmpty
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                rangePicker
                headlineStats
                trendCard
                prCard
                weeklySummaryCard
                bodyCard
                heatmapCard
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .scrollContentBackground(.hidden)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            MMEyebrow(text: range.eyebrow)
            Text("Your rhythm")
                .font(MMFont.largeTitle)
                .foregroundStyle(MMColor.textPrimary)
            Text(headerSubhead)
                .font(MMFont.subhead)
                .foregroundStyle(MMColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 6)
        .padding(.bottom, 4)
    }

    private var headerSubhead: String {
        let streak = currentStreak
        if streak == 0 { return "Steady beats loud. You're doing it." }
        return "Steady beats loud. \(streak) day\(streak == 1 ? "" : "s") in."
    }

    // MARK: - Segmented

    private var rangePicker: some View {
        Picker("Range", selection: $range) {
            ForEach(ProgressStats.Range.allCases) { r in
                Text(r.title).tag(r)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Headline stats

    private var headlineStats: some View {
        HStack(spacing: 10) {
            HeadlineStatTile(
                icon: "flame.fill",
                value: "\(currentStreak)",
                unit: currentStreak == 1 ? "day" : "days",
                label: "Current streak",
                tone: .primary
            )
            HeadlineStatTile(
                icon: "sun.max.fill",
                value: avgReadinessText,
                unit: "/ 10",
                label: "Avg readiness",
                tone: .secondary
            )
        }
    }

    private var currentStreak: Int {
        StreakCalculator.currentStreak(sessions: allSessions, profile: profile)
    }

    private var avgReadinessText: String {
        guard let avg = ProgressStats.averageReadiness(allCheckins, inLast: range.days) else {
            return "—"
        }
        return String(format: "%.1f", avg)
    }

    // MARK: - Trend

    private var trendCard: some View {
        let weeks = min(12, max(2, weeksFor(range)))
        let volumes = ProgressStats.weeklyVolumes(allSessions, weeks: weeks)
        let trend = ProgressStats.volumeTrendPercent(volumes)

        return MMCard(tone: .surface, radius: 22, padding: 18, shadow: .sm) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Workout volume")
                        .font(MMFont.headline)
                        .foregroundStyle(MMColor.textPrimary)
                    Spacer()
                    if let trend {
                        Text(trendText(trend))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(trend >= 0 ? MMColor.secondary : MMColor.textSecondary)
                    }
                }
                Text("Total sets per week")
                    .font(MMFont.caption1)
                    .foregroundStyle(MMColor.textSecondary)
                TrendLine(values: volumes.map(Double.init))
                    .frame(height: 130)
                    .padding(.top, 14)
            }
        }
    }

    private func trendText(_ pct: Int) -> String {
        let arrow = pct >= 0 ? "↑" : "↓"
        return "\(arrow) \(abs(pct))% vs last"
    }

    private func weeksFor(_ range: ProgressStats.Range) -> Int {
        switch range {
        case .week:    return 4
        case .month:   return 8
        case .quarter: return 12
        }
    }

    // MARK: - PRs

    @ViewBuilder
    private var prCard: some View {
        let prs = ProgressStats.recentPRs(allSessions, limit: 3)
        if !prs.isEmpty {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [MMColor.primary.opacity(0.16), .clear],
                            center: .center, startRadius: 4, endRadius: 110
                        )
                    )
                    .frame(width: 160, height: 160)
                    .offset(x: 40, y: -50)
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(MMColor.primary)
                        MMEyebrow(text: "Personal bests", color: MMColor.primary)
                        Spacer()
                        Text("recent")
                            .font(MMFont.caption1)
                            .foregroundStyle(MMColor.textTertiary)
                    }
                    VStack(spacing: 8) {
                        ForEach(prs) { pr in
                            PRRow(pr: pr, unit: profile.preferredUnit)
                        }
                    }
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [MMColor.primaryTint, MMColor.surfaceCard],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .mmShadow(.sm)
        }
    }

    // MARK: - Weekly summary (serif)

    private var weeklySummaryCard: some View {
        MMCard(tone: .surface, radius: 22, padding: 18, shadow: .sm) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(MMColor.textSecondary)
                    MMEyebrow(text: "This week")
                }
                weeklySummaryText
                    .font(.system(size: 21, weight: .regular, design: .serif))
                    .lineSpacing(6)
                    .foregroundStyle(MMColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var weeklySummaryText: Text {
        let cal = Calendar.current
        let highlight: (String) -> Text = { phrase in
            Text(phrase).foregroundColor(MMColor.primary).italic()
        }
        guard let week = cal.dateInterval(of: .weekOfYear, for: Date()) else {
            return Text("A quiet week. \(highlight("That counts too."))")
        }
        let workouts = allSessions.filter {
            $0.status != .restDayLogged && $0.status != .upcoming && week.contains($0.date)
        }.count
        let restDays = allSessions.filter { $0.status == .restDayLogged && week.contains($0.date) }.count
        let plannedDays = profile.weeklySchedule.filter { $0.templateCategory != nil }.count

        if workouts == 0 && restDays == 0 {
            return Text("A blank slate. \(highlight("Today's a fine day to start."))")
        }
        let plan = plannedDays > 0 ? "\(workouts) of \(plannedDays) planned workouts" : "\(workouts) workout\(workouts == 1 ? "" : "s")"
        let rest = restDays > 0 ? " \(restDays) rest day\(restDays == 1 ? "" : "s"), taken on purpose." : ""
        return Text("\(plan).\(rest) \(highlight("That's a lot of small yeses."))")
    }

    // MARK: - Body

    private var bodyCard: some View {
        MMCard(tone: .surface, radius: 22, padding: 18, shadow: .sm) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Body")
                        .font(MMFont.headline)
                        .foregroundStyle(MMColor.textPrimary)
                    Spacer()
                    Text("Log +")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(MMColor.primary)
                }

                if measurementRows.isEmpty {
                    Text("No measurements yet. Numbers help, but they aren't the point.")
                        .font(MMFont.subhead)
                        .foregroundStyle(MMColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    VStack(spacing: 10) {
                        ForEach(measurementRows, id: \.label) { row in
                            MeasureRow(row: row)
                        }
                    }
                }
            }
        }
    }

    private var measurementRows: [MeasureRowData] {
        var rows: [MeasureRowData] = []
        let weights = allMeasurements.filter { $0.type == "weight" }
        if let latest = weights.first {
            let prior = weights.dropFirst().first
            let delta = prior.map { d -> String in
                let diff = latest.value - d.value
                return String(format: "%+.1f", diff)
            }
            rows.append(MeasureRowData(
                label: "Weight",
                value: formatNumber(latest.value, places: 1),
                unit: latest.unit == .pounds ? "lb" : "kg",
                delta: delta
            ))
        }
        return rows
    }

    private func formatNumber(_ value: Double, places: Int) -> String {
        String(format: "%.\(places)f", value)
    }

    // MARK: - Heatmap

    private var heatmapCard: some View {
        MMCard(tone: .surface, radius: 22, padding: 18, shadow: .sm) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Readiness")
                    .font(MMFont.headline)
                    .foregroundStyle(MMColor.textPrimary)
                Text("84 days of morning check-ins")
                    .font(MMFont.caption1)
                    .foregroundStyle(MMColor.textSecondary)
                    .padding(.bottom, 10)
                MMHeatmap(values: readinessHeatmap)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    /// 12 weeks × 7 days, column-major. Maps each day to either the
    /// readiness score (0…1) or — if no check-in — to whether a session
    /// happened (gives the heatmap "shape" even if check-ins are sparse).
    private var readinessHeatmap: [Double] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        guard let earliest = cal.date(byAdding: .day, value: -7 * 12 + 1, to: today) else {
            return Array(repeating: 0, count: 84)
        }

        var byDay: [Date: Double] = [:]
        for c in allCheckins {
            if let r = c.readinessScore {
                byDay[cal.startOfDay(for: c.date)] = Double(r) / 10.0
            }
        }
        for s in allSessions where s.status != .restDayLogged && s.status != .upcoming {
            let day = cal.startOfDay(for: s.date)
            if byDay[day] == nil { byDay[day] = 0.5 }
        }

        var values: [Double] = []
        values.reserveCapacity(84)
        for col in 0..<12 {
            for row in 0..<7 {
                let dayOffset = col * 7 + row
                if let day = cal.date(byAdding: .day, value: dayOffset, to: earliest) {
                    values.append(byDay[day] ?? 0)
                } else {
                    values.append(0)
                }
            }
        }
        return values
    }

    // MARK: - Empty state

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
}

// MARK: - Headline stat tile

private struct HeadlineStatTile: View {
    let icon: String
    let value: String
    let unit: String
    let label: String
    enum Tone { case primary, secondary }
    let tone: Tone

    private var color: Color { tone == .primary ? MMColor.primary : MMColor.secondary }
    private var tint: Color { tone == .primary ? MMColor.primaryTint : MMColor.secondaryTint }
    private var muted: Color { tone == .primary ? MMColor.primaryMuted : MMColor.secondaryMuted }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(muted)
                    .frame(width: 30, height: 30)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
            }

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(MMColor.textPrimary)
                    .monospacedDigit()
                Text(unit)
                    .font(MMFont.footnote)
                    .foregroundStyle(MMColor.textSecondary)
            }

            Text(label)
                .font(MMFont.caption1)
                .foregroundStyle(MMColor.textSecondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [tint, MMColor.surfaceCard],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
        )
        .mmShadow(.sm)
    }
}

// MARK: - Trend line

private struct TrendLine: View {
    let values: [Double]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let maxV = max(1, values.max() ?? 1)
            let n = max(1, values.count - 1)
            let step = n > 0 ? w / CGFloat(n) : 0
            let points: [CGPoint] = values.enumerated().map { i, v in
                CGPoint(x: CGFloat(i) * step, y: h - CGFloat(v / maxV) * h)
            }

            ZStack {
                // Filled area
                Path { p in
                    guard let first = points.first else { return }
                    p.move(to: CGPoint(x: first.x, y: h))
                    p.addLine(to: first)
                    for pt in points.dropFirst() { p.addLine(to: pt) }
                    if let last = points.last { p.addLine(to: CGPoint(x: last.x, y: h)) }
                    p.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [MMColor.primary.opacity(0.22), MMColor.primary.opacity(0)],
                        startPoint: .top, endPoint: .bottom
                    )
                )

                // Line
                Path { p in
                    guard let first = points.first else { return }
                    p.move(to: first)
                    for pt in points.dropFirst() { p.addLine(to: pt) }
                }
                .stroke(MMColor.primary, style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))

                // Last-point marker
                if let last = points.last {
                    Circle()
                        .fill(MMColor.primary.opacity(0.18))
                        .frame(width: 16, height: 16)
                        .position(last)
                    Circle()
                        .fill(MMColor.primary)
                        .frame(width: 9, height: 9)
                        .overlay(
                            Circle()
                                .stroke(MMColor.surfaceCard, lineWidth: 2)
                        )
                        .position(last)
                }
            }
        }
    }
}

// MARK: - PR row

private struct PRRow: View {
    let pr: ProgressStats.RecentPR
    let unit: Unit

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(MMColor.primaryMuted)
                    .frame(width: 32, height: 32)
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(MMColor.primary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(pr.exerciseName)
                    .font(MMFont.footnote.weight(.semibold))
                    .foregroundStyle(MMColor.textPrimary)
                    .lineLimit(1)
                Text(relativeWhen(pr.date))
                    .font(MMFont.caption1)
                    .foregroundStyle(MMColor.textSecondary)
            }
            Spacer(minLength: 8)
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(valueText)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(MMColor.primary)
                    .monospacedDigit()
                Text(unitLabel)
                    .font(MMFont.caption1)
                    .foregroundStyle(MMColor.textSecondary)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(MMColor.surface)
        )
    }

    private var valueText: String {
        if let weight = pr.weight {
            return weight.truncatingRemainder(dividingBy: 1) == 0
                ? String(format: "%.0f", weight)
                : String(format: "%.1f", weight)
        }
        if let reps = pr.reps { return "\(reps)" }
        return "—"
    }

    private var unitLabel: String {
        if pr.weight != nil {
            let u = unit == .pounds ? "lb" : "kg"
            if let reps = pr.reps { return "\(u) × \(reps)" }
            return u
        }
        if pr.reps != nil { return "reps" }
        return ""
    }

    private func relativeWhen(_ date: Date) -> String {
        let cal = Calendar.current
        let days = cal.dateComponents([.day], from: cal.startOfDay(for: date), to: cal.startOfDay(for: Date())).day ?? 0
        if days == 0 { return "today" }
        if days == 1 { return "yesterday" }
        if days < 7  { return "\(days) days ago" }
        let weeks = days / 7
        return weeks == 1 ? "last week" : "\(weeks) weeks ago"
    }
}

// MARK: - Measure row

fileprivate struct MeasureRowData {
    let label: String
    let value: String
    let unit: String
    let delta: String?
}

private struct MeasureRow: View {
    let row: MeasureRowData

    var body: some View {
        HStack(spacing: 12) {
            Text(row.label)
                .font(MMFont.body)
                .foregroundStyle(MMColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(row.value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(MMColor.textPrimary)
                    .monospacedDigit()
                Text(row.unit)
                    .font(MMFont.caption1)
                    .foregroundStyle(MMColor.textSecondary)
            }

            if let delta = row.delta {
                Text(delta)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(MMColor.textSecondary)
                    .frame(width: 56, alignment: .trailing)
            } else {
                Color.clear.frame(width: 56)
            }
        }
    }
}
