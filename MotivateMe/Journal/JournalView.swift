//
//  JournalView.swift
//  MotivateMe
//
//  Journal tab — list of entries with the day's prompt at the top.
//  Tapping the prompt or the pencil opens the compose sheet.
//  Tapping a card pushes the read view.
//

import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]

    @State private var showingCompose = false

    var body: some View {
        NavigationStack {
            ZStack {
                MMColor.bg.ignoresSafeArea()

                if entries.isEmpty {
                    JournalEmptyState(onCompose: { showingCompose = true })
                } else {
                    list
                }
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingCompose = true } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundStyle(MMColor.primary)
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
            }
            .sheet(isPresented: $showingCompose) {
                JournalComposeView()
            }
        }
    }

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                JournalSubtitle(count: entries.count, streak: writingStreak)

                TodayPromptCard(prompt: JournalPrompts.today()) {
                    showingCompose = true
                }

                ForEach(grouped, id: \.label) { group in
                    VStack(alignment: .leading, spacing: 10) {
                        MMEyebrow(text: group.label)
                            .padding(.leading, 4)
                        ForEach(group.entries) { entry in
                            NavigationLink {
                                JournalReadView(entry: entry)
                            } label: {
                                JournalCardRow(entry: entry)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 32)
        }
        .scrollContentBackground(.hidden)
    }

    // MARK: - Grouping

    private struct Group {
        let label: String
        let entries: [JournalEntry]
    }

    private var grouped: [Group] {
        var result: [Group] = []
        var current: (label: String, items: [JournalEntry])? = nil
        for entry in entries {
            let label = JournalDateFormat.dayLabel(entry.date)
            if current?.label == label {
                current?.items.append(entry)
            } else {
                if let c = current { result.append(Group(label: c.label, entries: c.items)) }
                current = (label, [entry])
            }
        }
        if let c = current { result.append(Group(label: c.label, entries: c.items)) }
        return result
    }

    private var writingStreak: Int {
        let cal = Calendar.current
        var streak = 0
        var day = cal.startOfDay(for: Date())
        let days = Set(entries.map { cal.startOfDay(for: $0.date) })
        while days.contains(day) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }
}

// MARK: - Subtitle

private struct JournalSubtitle: View {
    let count: Int
    let streak: Int

    var body: some View {
        let entries = "\(count) entr\(count == 1 ? "y" : "ies")"
        let streakText = streak > 0 ? " · \(streak) day writing streak" : ""
        Text(entries + streakText)
            .font(MMFont.subhead)
            .foregroundStyle(MMColor.textSecondary)
    }
}

// MARK: - Today's prompt card

private struct TodayPromptCard: View {
    let prompt: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [MMColor.primary.opacity(0.18), .clear],
                            center: .center, startRadius: 4, endRadius: 110
                        )
                    )
                    .frame(width: 160, height: 160)
                    .offset(x: 40, y: -50)
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(MMColor.primary)
                        MMEyebrow(text: "Today's prompt", color: MMColor.primary)
                    }

                    Text(prompt)
                        .font(.system(size: 22, weight: .regular, design: .serif).italic())
                        .foregroundStyle(MMColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(4)

                    HStack(spacing: 6) {
                        Text("Start writing")
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(MMColor.primary)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [MMColor.primaryTint, MMColor.surfaceCard],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .mmShadow(.sm)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Card row

private struct JournalCardRow: View {
    let entry: JournalEntry

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(MMColor.primaryMuted)
                    .frame(width: 42, height: 42)
                Text(entry.mood.emoji)
                    .font(.system(size: 22))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(entry.title.isEmpty ? "Untitled" : entry.title)
                        .font(MMFont.headline)
                        .foregroundStyle(MMColor.textPrimary)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    Text(entry.date.formatted(date: .omitted, time: .shortened))
                        .font(MMFont.caption1)
                        .foregroundStyle(MMColor.textTertiary)
                }
                Text(entry.body)
                    .font(.system(size: 14, design: .serif))
                    .foregroundStyle(MMColor.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(MMColor.surfaceCard)
        )
        .mmShadow(.sm)
    }
}

// MARK: - Empty state

private struct JournalEmptyState: View {
    let onCompose: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(MMColor.primaryTint)
                    .frame(width: 76, height: 76)
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(MMColor.primary)
            }
            VStack(spacing: 6) {
                Text("A quiet place to think")
                    .font(MMFont.title3)
                    .foregroundStyle(MMColor.textPrimary)
                Text("Write a few lines a day. Just for you.")
                    .font(MMFont.subhead)
                    .foregroundStyle(MMColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
            }
            MMPillButton(
                variant: .primary, size: .md,
                icon: "square.and.pencil", fullWidth: false,
                title: "Write today's entry"
            ) { onCompose() }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Date formatting

enum JournalDateFormat {
    static func dayLabel(_ date: Date) -> String {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let day = cal.startOfDay(for: date)
        let diff = cal.dateComponents([.day], from: day, to: today).day ?? 0
        if diff == 0 { return "Today" }
        if diff == 1 { return "Yesterday" }
        if diff < 7 {
            return date.formatted(.dateTime.weekday(.wide))
        }
        return date.formatted(.dateTime.month(.wide).day())
    }

    static func fullLabel(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.wide).month(.wide).day())
    }
}
