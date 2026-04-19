//
//  FinishWorkoutSheet.swift
//  MotivateMe
//
//  Presented before saving a workout. Captures how hard it felt and an
//  optional note. Both fields write to the Session via the caller's
//  closure, so this sheet stays decoupled from SwiftData.
//

import SwiftUI

struct FinishWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var effort: EffortLevel = .moderate
    @State private var notes: String = ""
    let onSave: (_ effort: EffortLevel?, _ notes: String?) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("How did it feel?") {
                    Picker("Effort", selection: $effort) {
                        ForEach(EffortLevel.allCases, id: \.self) { level in
                            Text(level.displayName).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Notes (optional)") {
                    TextField("Anything to remember?", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Finish workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Skip") {
                        onSave(nil, nil)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let trimmed = notes.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSave(effort, trimmed.isEmpty ? nil : trimmed)
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}
