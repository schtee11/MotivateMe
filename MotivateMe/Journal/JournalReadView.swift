//
//  JournalReadView.swift
//  MotivateMe
//
//  Detail view for a single journal entry. Long-form serif body, mood
//  chip, gratitude card, and an Edit toolbar item that opens compose
//  in edit mode.
//

import SwiftUI
import SwiftData

struct JournalReadView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var entry: JournalEntry

    @State private var showingEdit = false
    @State private var showingDeleteConfirm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header

                if !entry.title.isEmpty {
                    Text(entry.title)
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .foregroundStyle(MMColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text(entry.body)
                    .font(.system(size: 18, design: .serif))
                    .lineSpacing(6)
                    .foregroundStyle(MMColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                if !entry.grateful.isEmpty {
                    gratitudeCard
                }

                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11, weight: .regular))
                    Text("Kept on this device")
                }
                .font(MMFont.caption1)
                .foregroundStyle(MMColor.textTertiary)
                .padding(.top, 4)
            }
            .padding(.horizontal, 22)
            .padding(.top, 12)
            .padding(.bottom, 44)
        }
        .scrollContentBackground(.hidden)
        .background(MMColor.bg.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { showingEdit = true } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        showingDeleteConfirm = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(MMColor.primary)
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            JournalComposeView(editing: entry)
        }
        .confirmationDialog("Delete this entry?", isPresented: $showingDeleteConfirm) {
            Button("Delete", role: .destructive) {
                modelContext.delete(entry)
                try? modelContext.save()
                dismiss()
            }
        } message: {
            Text("This can't be undone.")
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(MMColor.primaryMuted)
                    .frame(width: 36, height: 36)
                Text(entry.mood.emoji).font(.system(size: 18))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(JournalDateFormat.fullLabel(entry.date))
                    .font(MMFont.footnote.weight(.semibold))
                    .foregroundStyle(MMColor.textPrimary)
                Text("Feeling \(entry.mood.label.lowercased()) · \(entry.date.formatted(date: .omitted, time: .shortened))")
                    .font(MMFont.caption1)
                    .foregroundStyle(MMColor.textSecondary)
            }
            Spacer()
        }
    }

    private var gratitudeCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(MMColor.secondary)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 6) {
                MMEyebrow(text: "Grateful for", color: MMColor.secondary)
                Text(entry.grateful)
                    .font(.system(size: 16, design: .serif).italic())
                    .foregroundStyle(MMColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(MMColor.secondaryTint)
        )
    }
}
