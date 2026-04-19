//
//  SettingsView.swift
//  MotivateMe
//
//  Profile editor — post-onboarding. Binds directly to @Model UserProfile,
//  so every change persists via SwiftData autosave. The one piece of
//  non-trivial logic: when the user changes splitStyle or daysPerWeek
//  we offer to regenerate the weekly schedule (since the existing one may
//  contain categories the new split doesn't offer).
//

import SwiftUI

struct SettingsView: View {
    @Bindable var profile: UserProfile

    @State private var showRegenerateAlert: Bool = false
    @State private var pendingSplit: SplitStyle?
    @State private var pendingDays: Int?

    var body: some View {
        NavigationStack {
            Form {
                prefsSection
                planSection
                equipmentSection
                metaSection
            }
            .navigationTitle("Settings")
            .alert(
                "Regenerate schedule?",
                isPresented: $showRegenerateAlert,
                actions: regenerateActions,
                message: { Text("Your weekly plan changed. Regenerate workout days to match? Your custom edits will be replaced.") }
            )
        }
    }

    // MARK: - Preferences

    private var prefsSection: some View {
        Section("Preferences") {
            Picker("Units", selection: $profile.preferredUnit) {
                ForEach([Unit.pounds, .kilograms], id: \.self) { unit in
                    Text(unit.displayName).tag(unit)
                }
            }

            Picker("Experience", selection: $profile.experienceLevel) {
                ForEach(ExperienceLevel.allCases, id: \.self) { level in
                    Text(level.displayName).tag(level)
                }
            }
        }
    }

    // MARK: - Plan

    private var planSection: some View {
        Section {
            Picker("Split style", selection: Binding(
                get: { profile.splitStyle },
                set: { newValue in
                    guard newValue != profile.splitStyle else { return }
                    pendingSplit = newValue
                    profile.splitStyle = newValue
                    profile.updatedAt = Date()
                    showRegenerateAlert = true
                }
            )) {
                ForEach(SplitStyle.allCases, id: \.self) { style in
                    Text(style.displayName).tag(style)
                }
            }

            Stepper(value: Binding(
                get: { profile.daysPerWeek },
                set: { newValue in
                    guard newValue != profile.daysPerWeek else { return }
                    pendingDays = newValue
                    profile.daysPerWeek = newValue
                    profile.updatedAt = Date()
                    showRegenerateAlert = true
                }
            ), in: 1...7) {
                HStack {
                    Text("Days / week")
                    Spacer()
                    Text("\(profile.daysPerWeek)")
                        .foregroundStyle(.secondary)
                }
            }

            Stepper(value: $profile.sessionLengthMinutes, in: 15...90, step: 5) {
                HStack {
                    Text("Target session length")
                    Spacer()
                    Text("\(profile.sessionLengthMinutes) min")
                        .foregroundStyle(.secondary)
                }
            }

            NavigationLink("Edit weekly schedule") {
                EditScheduleView(profile: profile)
            }
        } header: {
            Text("Plan")
        } footer: {
            Text("Changing split or days offers a one-tap schedule regeneration.")
        }
    }

    // MARK: - Equipment

    private var equipmentSection: some View {
        Section {
            ForEach(Equipment.allCases, id: \.self) { equipment in
                let isSelected = profile.availableEquipment.contains(equipment)
                Button {
                    toggleEquipment(equipment)
                } label: {
                    HStack {
                        Text(equipment.displayName)
                            .foregroundStyle(.primary)
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
            }
        } header: {
            Text("Equipment available")
        } footer: {
            Text("Only workouts that fit your equipment are shown.")
        }
    }

    private var metaSection: some View {
        Section {
            HStack {
                Text("Member since")
                Spacer()
                Text(profile.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Profile")
        }
    }

    // MARK: - Actions

    @ViewBuilder
    private func regenerateActions() -> some View {
        Button("Regenerate") {
            profile.weeklySchedule = ScheduleGenerator.defaultSchedule(
                splitStyle: profile.splitStyle,
                daysPerWeek: profile.daysPerWeek
            )
            profile.updatedAt = Date()
            pendingSplit = nil
            pendingDays = nil
        }
        Button("Keep current", role: .cancel) {
            pendingSplit = nil
            pendingDays = nil
        }
    }

    private func toggleEquipment(_ equipment: Equipment) {
        if let index = profile.availableEquipment.firstIndex(of: equipment) {
            profile.availableEquipment.remove(at: index)
        } else {
            profile.availableEquipment.append(equipment)
        }
        profile.updatedAt = Date()
    }
}
