//
//  EditScheduleView.swift
//  MotivateMe
//
//  Lets the user reassign each weekday to a category (or rest). The set of
//  offered categories is tied to the profile's splitStyle — changing the
//  split itself lives on a settings screen (not built yet), so this view
//  only edits assignments within the current split.
//
//  Mutations write directly to the @Model UserProfile and are persisted
//  by SwiftData's autosave; there is no separate save step.
//

import SwiftUI

struct EditScheduleView: View {
    @Bindable var profile: UserProfile

    var body: some View {
        List {
            Section {
                ForEach(Weekday.allCases, id: \.self) { weekday in
                    dayRow(weekday: weekday)
                }
            } footer: {
                Text("Tap a day to change its focus. Rest days let your body adapt — aim for at least one per week.")
            }
        }
        .navigationTitle("Edit Schedule")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func dayRow(weekday: Weekday) -> some View {
        HStack {
            Text(weekday.displayName)
            Spacer()
            Menu {
                Button("Rest") { setCategory(nil, for: weekday) }
                ForEach(availableCategories, id: \.self) { category in
                    Button(category.displayName) { setCategory(category, for: weekday) }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(currentLabel(for: weekday))
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }

    // The categories the user's split offers, plus mobility as a universal
    // recovery-day option. Rest is handled separately in the menu.
    private var availableCategories: [TemplateCategory] {
        let base: [TemplateCategory]
        switch profile.splitStyle {
        case .fullBody:     base = [.fullBody]
        case .upperLower:   base = [.upper, .lower]
        case .pushPullLegs: base = [.push, .pull, .legs]
        }
        return base + [.mobility]
    }

    private func currentLabel(for weekday: Weekday) -> String {
        guard let entry = profile.weeklySchedule.first(where: { $0.weekday == weekday }) else {
            return "Rest"
        }
        return entry.templateCategory?.displayName ?? "Rest"
    }

    private func setCategory(_ category: TemplateCategory?, for weekday: Weekday) {
        if let index = profile.weeklySchedule.firstIndex(where: { $0.weekday == weekday }) {
            profile.weeklySchedule[index].templateCategory = category
        } else {
            profile.weeklySchedule.append(
                ScheduleEntry(weekday: weekday, templateCategory: category)
            )
        }
        profile.updatedAt = Date()
    }
}
