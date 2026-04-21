//
//  FinishWorkoutSheet.swift
//  MotivateMe
//
//  Presented before saving a workout. In the Morning Light design this
//  is the "finish sheet": how it felt, a short note, and a warm save
//  button. Both fields feed the caller's closure so this sheet stays
//  decoupled from SwiftData.
//

import SwiftUI

struct FinishWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var effort: EffortLevel = .moderate
    @State private var notes: String = ""
    let onSave: (_ effort: EffortLevel?, _ notes: String?) -> Void

    // Matches the design's Tough / Steady / Strong / Easy chips.
    // We collapse to the existing 3-level EffortLevel model.
    private let chips: [(label: String, level: EffortLevel)] = [
        ("Tough",  .hard),
        ("Steady", .moderate),
        ("Strong", .moderate),
        ("Easy",   .easy),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    feelCard
                    notesCard
                    MMPillButton(
                        variant: .primary,
                        icon: "checkmark.seal.fill",
                        title: "Save & finish"
                    ) {
                        let trimmed = notes.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSave(effort, trimmed.isEmpty ? nil : trimmed)
                        dismiss()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 32)
            }
            .scrollContentBackground(.hidden)
            .background(MMColor.bg.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Nicely done")
                        .font(MMFont.headline)
                        .foregroundStyle(MMColor.textPrimary)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Skip") {
                        onSave(nil, nil)
                        dismiss()
                    }
                    .foregroundStyle(MMColor.primary)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Session saved")
                .font(MMFont.title1)
                .foregroundStyle(MMColor.textPrimary)
            Text("A quick note to your future self.")
                .font(MMFont.subhead)
                .foregroundStyle(MMColor.textSecondary)
        }
    }

    private var feelCard: some View {
        MMCard(tone: .surface, radius: 22, padding: 18, shadow: .sm) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(MMColor.primary)
                    Text("How did that feel?")
                        .font(MMFont.headline)
                        .foregroundStyle(MMColor.textPrimary)
                }

                HStack(spacing: 8) {
                    ForEach(chips.indices, id: \.self) { i in
                        let chip = chips[i]
                        let isSelected = effort == chip.level
                        Button {
                            effort = chip.level
                        } label: {
                            Text(chip.label)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule().fill(isSelected ? MMColor.primaryMuted : MMColor.surfaceInput)
                                )
                                .foregroundStyle(isSelected ? MMColor.primary : MMColor.textSecondary)
                                .overlay(
                                    Capsule().strokeBorder(
                                        isSelected ? MMColor.primary : .clear,
                                        lineWidth: 1.5
                                    )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var notesCard: some View {
        MMCard(tone: .surface, radius: 22, padding: 18, shadow: .sm) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Anything to remember?")
                    .font(MMFont.headline)
                    .foregroundStyle(MMColor.textPrimary)
                Text("Optional — a cue, a win, how the last set felt.")
                    .font(MMFont.footnote)
                    .foregroundStyle(MMColor.textSecondary)

                TextField("A line or two…", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
                    .font(MMFont.body)
                    .foregroundStyle(MMColor.textPrimary)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(MMColor.surfaceInput)
                    )
            }
        }
    }
}
