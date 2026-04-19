//
//  TodayView.swift
//  MotivateMe
//
//  Post-onboarding landing screen. Reads the user's weekly schedule,
//  looks up today's category, and recommends a matching template from
//  the library. Three states: workout day with a match, workout day
//  without a compatible template (equipment mismatch), and rest day.
//
//  Start/Swap/Edit actions are stubbed for this first pass — they'll
//  wire to real flows in follow-up commits.
//

import SwiftUI

struct TodayView: View {
    @Bindable var profile: UserProfile

    private var todayWeekday: Weekday { Weekday.from(date: Date()) }

    private var todayEntry: ScheduleEntry? {
        profile.weeklySchedule.first { $0.weekday == todayWeekday }
    }

    private var recommendedTemplate: WorkoutTemplate? {
        guard let category = todayEntry?.templateCategory else { return nil }
        return TemplateRecommender.recommend(category: category, for: profile)
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
        if let category = todayEntry?.templateCategory {
            if let template = recommendedTemplate {
                workoutCard(template: template, category: category)
            } else {
                noMatchCard(category: category)
            }
        } else {
            restDayCard
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
                // TODO: start workout flow
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
