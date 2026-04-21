//
//  DailyCheckinSheet.swift
//  MotivateMe
//
//  Prompts the user for a quick morning read on how they feel. Writes (or
//  updates) today's DailyCheckin row via the model's upsert helper.
//

import SwiftUI
import SwiftData

struct DailyCheckinSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ErrorPresenter.self) private var errorPresenter

    @State private var readiness: Double = 7
    @State private var energy: String = ""
    @State private var hasLoaded: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Wiped")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(Int(readiness))")
                                .font(.title2).bold().monospacedDigit()
                            Spacer()
                            Text("Peak")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $readiness, in: 1...10, step: 1)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("How ready do you feel?")
                } footer: {
                    Text("Trust your gut. This adjusts nothing automatically — just a signal for you.")
                }

                Section("Anything on your mind? (optional)") {
                    TextField("Sleep, soreness, stress…", text: $energy, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Morning check-in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .bold()
                }
            }
            .task {
                guard !hasLoaded else { return }
                hasLoaded = true
                loadExisting()
            }
        }
    }

    private func loadExisting() {
        guard let existing = try? DailyCheckin.upsert(for: Date(), in: modelContext),
              let score = existing.readinessScore
        else { return }
        readiness = Double(score)
        energy = existing.selfReportedEnergy ?? ""
    }

    private func save() {
        do {
            let checkin = try DailyCheckin.upsert(for: Date(), in: modelContext)
            checkin.readinessScore = Int(readiness)
            checkin.readinessSource = .selfReport
            let trimmed = energy.trimmingCharacters(in: .whitespacesAndNewlines)
            checkin.selfReportedEnergy = trimmed.isEmpty ? nil : trimmed
            try modelContext.save()
        } catch {
            errorPresenter.present(error, context: "Saving your check-in")
        }
    }
}
