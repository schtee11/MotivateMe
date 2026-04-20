//
//  JournalComposeView.swift
//  MotivateMe
//
//  Compose / edit a journal entry. Mood picker, optional serif title,
//  prompt subtitle, serif body, optional gratitude card. Save inserts
//  a new entry; pass an existing entry to edit it in place.
//

import SwiftUI
import SwiftData

struct JournalComposeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// If non-nil, save mutates this entry instead of inserting a new one.
    var editing: JournalEntry?

    @State private var mood: JournalMood
    @State private var title: String
    @State private var bodyText: String
    @State private var grateful: String
    @State private var prompt: String

    init(editing: JournalEntry? = nil) {
        self.editing = editing
        _mood = State(initialValue: editing?.mood ?? .okay)
        _title = State(initialValue: editing?.title ?? "")
        _bodyText = State(initialValue: editing?.body ?? "")
        _grateful = State(initialValue: editing?.grateful ?? "")
        _prompt = State(initialValue: editing?.prompt ?? JournalPrompts.today())
    }

    private var canSave: Bool {
        !bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MMColor.bg.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        moodPicker

                        TextField("Title (optional)", text: $title, axis: .vertical)
                            .font(.system(size: 26, weight: .semibold, design: .serif))
                            .foregroundStyle(MMColor.textPrimary)
                            .tint(MMColor.primary)
                            .padding(.top, 4)

                        Rectangle()
                            .fill(MMColor.separator)
                            .frame(height: 0.5)

                        Text("Prompt · \(prompt)")
                            .font(MMFont.footnote.italic())
                            .foregroundStyle(MMColor.textTertiary)

                        TextField("Start where you are…", text: $bodyText, axis: .vertical)
                            .font(.system(size: 17, design: .serif))
                            .lineSpacing(6)
                            .foregroundStyle(MMColor.textPrimary)
                            .tint(MMColor.primary)
                            .frame(minHeight: 220, alignment: .topLeading)

                        gratitudeCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    .padding(.bottom, 32)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(MMColor.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: save)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(canSave ? MMColor.primary : MMColor.textTertiary)
                        .disabled(!canSave)
                }
            }
        }
    }

    // MARK: - Mood

    private var moodPicker: some View {
        HStack(spacing: 8) {
            ForEach(JournalMood.allCases, id: \.self) { m in
                let selected = mood == m
                Button {
                    mood = m
                } label: {
                    VStack(spacing: 4) {
                        Text(m.emoji).font(.system(size: 22))
                        Text(m.label)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(selected ? MMColor.primary : MMColor.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(selected ? MMColor.primaryMuted : MMColor.surfaceInput)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(selected ? MMColor.primary : .clear, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Gratitude

    private var gratitudeCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            MMEyebrow(text: "One gratitude (optional)", color: MMColor.secondary)
            TextField("Even small counts.", text: $grateful, axis: .vertical)
                .font(.system(size: 16, design: .serif).italic())
                .tint(MMColor.secondary)
                .foregroundStyle(MMColor.textPrimary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(MMColor.secondaryTint)
        )
    }

    // MARK: - Save

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBody = bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedGrateful = grateful.trimmingCharacters(in: .whitespacesAndNewlines)

        if let editing {
            editing.mood = mood
            editing.title = trimmedTitle
            editing.body = trimmedBody
            editing.grateful = trimmedGrateful
            editing.prompt = prompt
        } else {
            let entry = JournalEntry(
                date: Date(),
                mood: mood,
                title: trimmedTitle,
                body: trimmedBody,
                prompt: prompt,
                grateful: trimmedGrateful
            )
            modelContext.insert(entry)
        }
        try? modelContext.save()
        dismiss()
    }
}
