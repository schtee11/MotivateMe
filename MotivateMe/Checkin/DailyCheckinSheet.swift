//
//  DailyCheckinSheet.swift
//  MotivateMe
//
//  Morning check-in dressed in the "Morning Light" palette. The reading
//  uses a 10-bar peach selector that warms as the value rises. A small
//  italic prompt below the bars invites — but never demands — a note.
//

import SwiftUI
import SwiftData

struct DailyCheckinSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ErrorPresenter.self) private var errorPresenter

    @State private var readiness: Int = 7
    @State private var energy: String = ""
    @State private var hasLoaded: Bool = false

    private var greetingTitle: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Morning." }
        if hour < 18 { return "Afternoon." }
        return "Evening."
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    headerCopy
                    readinessCard
                    notesCard
                    privacyFooter
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 32)
            }
            .scrollContentBackground(.hidden)
            .background(MMColor.bg.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Check-in")
                        .font(MMFont.headline)
                        .foregroundStyle(MMColor.textPrimary)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(MMColor.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(MMColor.primary)
                }
            }
            .task {
                guard !hasLoaded else { return }
                hasLoaded = true
                loadExisting()
            }
        }
    }

    // MARK: - Sections

    private var headerCopy: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greetingTitle)
                .font(MMFont.title1)
                .foregroundStyle(MMColor.textPrimary)
            Text("A minute of noticing. No wrong answers.")
                .font(MMFont.subhead)
                .foregroundStyle(MMColor.textSecondary)
        }
    }

    private var readinessCard: some View {
        MMCard(tone: .surface, radius: 24, padding: 20, shadow: .md) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "sun.max.fill")
                        .foregroundStyle(MMColor.primary)
                    Text("How ready do you feel?")
                        .font(MMFont.headline)
                        .foregroundStyle(MMColor.textPrimary)
                    Spacer()
                    Text("\(readiness)/10")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(MMColor.textTertiary)
                }

                MMReadinessBars(value: $readiness)

                Text(readinessCopy(readiness))
                    .font(MMFont.quote)
                    .foregroundStyle(MMColor.textSecondary)
                    .padding(.top, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var notesCard: some View {
        MMCard(tone: .surface, radius: 22, padding: 18, shadow: .sm) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Anything on your mind?")
                    .font(MMFont.headline)
                    .foregroundStyle(MMColor.textPrimary)
                Text("Sleep, soreness, stress — whatever you want to remember.")
                    .font(MMFont.footnote)
                    .foregroundStyle(MMColor.textSecondary)

                TextField("A few words…", text: $energy, axis: .vertical)
                    .lineLimit(2...5)
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

    private var privacyFooter: some View {
        Text("Your check-ins stay on your device.")
            .font(MMFont.footnote)
            .foregroundStyle(MMColor.textTertiary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 4)
    }

    // MARK: - Persistence

    private func loadExisting() {
        guard let existing = try? DailyCheckin.upsert(for: Date(), in: modelContext),
              let score = existing.readinessScore
        else { return }
        readiness = score
        energy = existing.selfReportedEnergy ?? ""
    }

    private func save() {
        do {
            let checkin = try DailyCheckin.upsert(for: Date(), in: modelContext)
            checkin.readinessScore = readiness
            checkin.readinessSource = .selfReport
            let trimmed = energy.trimmingCharacters(in: .whitespacesAndNewlines)
            checkin.selfReportedEnergy = trimmed.isEmpty ? nil : trimmed
            try modelContext.save()
        } catch {
            errorPresenter.present(error, context: "Saving your check-in")
        }
    }

    private func readinessCopy(_ n: Int) -> String {
        switch n {
        case ...3:  return "Feeling wiped. Be kind today."
        case 4...5: return "A little flat. Easy is enough."
        case 6...7: return "Steady. A good day to show up."
        default:    return "Strong. Ride it gently — no need to push."
        }
    }
}
