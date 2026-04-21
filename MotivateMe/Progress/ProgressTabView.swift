//
//  ProgressTabView.swift
//  MotivateMe
//
//  4th tab. Shows the user evidence that the work is paying off:
//  current streak, sessions this month, weekly volume trend, and the
//  most recent PRs. Read-only — drives motivation, not action.
//
//  Named *TabView to avoid collision with SwiftUI's built-in ProgressView.
//

import SwiftUI
import SwiftData
import Charts

struct ProgressTabView: View {
    @Bindable var profile: UserProfile
    @Query(sort: \Session.date, order: .reverse) private var allSessions: [Session]
    @Query(sort: \BodyMeasurement.date, order: .reverse) private var allMeasurements: [BodyMeasurement]

    var body: some View {
        NavigationStack {
            Group {
                if hasNoData {
                    emptyState
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            headlineCard
                            weeklyChartCard
                            measurementsCard
                            recentPRsCard
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Progress")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        MeasurementsView(profile: profile)
                    } label: {
                        Image(systemName: "scalemass")
                    }
                }
            }
        }
    }

    private var hasNoData: Bool {
        let noSessions = allSessions.allSatisfy { $0.status == .restDayLogged || $0.status == .upcoming }
        let noMeasurements = !allMeasurements.contains { $0.type == "weight" }
        return noSessions && noMeasurements
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("Nothing to chart yet")
                .font(.headline)
            Text("Complete a few workouts and your progress will show up here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

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

    private var headlineCard: some View {
        HStack(spacing: 0) {
            statCell(
                value: "\(streak)",
                label: streak == 1 ? "day streak" : "day streak",
                symbol: "flame.fill",
                tint: .orange
            )
            divider
            statCell(
                value: "\(monthCount)",
                label: monthCount == 1 ? "this month" : "this month",
                symbol: "checkmark.circle.fill",
                tint: .accentColor
            )
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.08))
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.2))
            .frame(width: 1, height: 36)
    }

    private func statCell(value: String, label: String, symbol: String, tint: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .foregroundStyle(tint)
                Text(value)
                    .font(.title).bold()
                    .monospacedDigit()
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var weeklyChartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 6 weeks")
                .font(.headline)
            Chart(weekBuckets) { bucket in
                BarMark(
                    x: .value("Week", bucket.weekStart, unit: .weekOfYear),
                    y: .value("Sessions", bucket.count)
                )
                .foregroundStyle(Color.accentColor)
                .cornerRadius(4)
            }
            .frame(height: 140)
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 3))
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .weekOfYear)) { value in
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        .font(.caption2)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.08))
        )
    }

    private var latestWeight: BodyMeasurement? {
        allMeasurements.first { $0.type == "weight" }
    }

    private var weightDelta: (current: Double, previous: Double, unit: Unit)? {
        let weights = allMeasurements.filter { $0.type == "weight" }
        guard let current = weights.first, let previous = weights.dropFirst().first else { return nil }
        return (current.value, previous.value, current.unit)
    }

    @ViewBuilder
    private var measurementsCard: some View {
        NavigationLink {
            MeasurementsView(profile: profile)
        } label: {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "scalemass")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Weight")
                        .font(.subheadline).bold()
                        .foregroundStyle(.primary)
                    if let latest = latestWeight {
                        Text(formatWeight(latest.value, unit: latest.unit)
                             + " \u{00B7} " + latest.date.formatted(.dateTime.month(.abbreviated).day()))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Tap to log your first entry")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if let delta = weightDelta {
                    deltaBadge(current: delta.current, previous: delta.previous, unit: delta.unit)
                }
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.secondary.opacity(0.08))
            )
        }
        .buttonStyle(.plain)
    }

    private func deltaBadge(current: Double, previous: Double, unit: Unit) -> some View {
        let diff = current - previous
        let sign = diff > 0 ? "+" : (diff < 0 ? "−" : "")
        let magnitude = abs(diff)
        let formatted = magnitude.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", magnitude)
            : String(format: "%.1f", magnitude)
        let suffix = unit == .pounds ? "lb" : "kg"
        return Text("\(sign)\(formatted) \(suffix)")
            .font(.caption).bold()
            .monospacedDigit()
            .foregroundStyle(.secondary)
    }

    private func formatWeight(_ value: Double, unit: Unit) -> String {
        let number = value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
        let suffix = unit == .pounds ? "lb" : "kg"
        return "\(number) \(suffix)"
    }

    @ViewBuilder
    private var recentPRsCard: some View {
        if recentPRs.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.orange)
                    Text("Recent PRs")
                        .font(.headline)
                }
                VStack(spacing: 8) {
                    ForEach(recentPRs) { pr in
                        prRow(pr)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.secondary.opacity(0.08))
            )
        }
    }

    private func prRow(_ pr: ProgressStats.RecentPR) -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(pr.exerciseName)
                    .font(.subheadline).bold()
                Text(pr.date.formatted(.dateTime.month(.abbreviated).day()))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(prValueText(pr))
                .font(.subheadline).bold()
                .monospacedDigit()
                .foregroundStyle(Color.accentColor)
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
}
