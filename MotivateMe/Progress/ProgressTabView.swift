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
                            recentPRsCard
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Progress")
        }
    }

    private var hasNoData: Bool {
        allSessions.allSatisfy { $0.status == .restDayLogged || $0.status == .upcoming }
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
