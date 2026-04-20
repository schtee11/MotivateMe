//
//  SettingsView.swift
//  MotivateMe
//
//  Profile editor. Morning Light treatment uses iOS grouped-inset
//  Sections with colored icon tiles, gentle micro-copy, a "Library" row
//  group, and a footer affirmation.
//
//  Switching split or daysPerWeek offers a one-tap schedule
//  regeneration alert (the existing schedule may contain categories
//  the new split doesn't offer).
//

import SwiftUI

struct SettingsView: View {
    @Bindable var profile: UserProfile

    @State private var showRegenerateAlert: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                headerCopy
                preferencesSection
                planSection
                equipmentSection
                aboutSection
                affirmationFooter
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 32)
        }
        .scrollContentBackground(.hidden)
        .background(MMColor.bg.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .alert(
            "Regenerate schedule?",
            isPresented: $showRegenerateAlert,
            actions: regenerateActions,
            message: { Text("Your weekly plan changed. Regenerate workout days to match? Your custom edits will be replaced.") }
        )
    }

    private var headerCopy: some View {
        Text("A handful of switches. That's all.")
            .font(MMFont.subhead)
            .foregroundStyle(MMColor.textSecondary)
            .padding(.horizontal, 4)
    }

    // MARK: - Preferences

    private var preferencesSection: some View {
        MMSettingsSection(title: "Preferences") {
            MMSettingsRow(
                icon: "scalemass.fill",
                iconBackground: MMColor.secondary
            ) {
                MMSettingsLabel(title: "Units", subtitle: "Weight & measurements")
                Spacer(minLength: 8)
                Picker("Units", selection: $profile.preferredUnit) {
                    ForEach([Unit.pounds, .kilograms], id: \.self) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
                .pickerStyle(.menu)
                .tint(MMColor.primary)
            }

            MMSettingsRow(
                icon: "figure.flexibility",
                iconBackground: MMColor.primary,
                isLast: true
            ) {
                MMSettingsLabel(title: "Experience", subtitle: profile.experienceLevel.descriptionText)
                Spacer(minLength: 8)
                Picker("Experience", selection: $profile.experienceLevel) {
                    ForEach(ExperienceLevel.allCases, id: \.self) { level in
                        Text(level.displayName).tag(level)
                    }
                }
                .pickerStyle(.menu)
                .tint(MMColor.primary)
            }
        }
    }

    // MARK: - Plan

    private var planSection: some View {
        MMSettingsSection(
            title: "Your plan",
            footer: "Changing split or days offers a one-tap schedule regeneration."
        ) {
            MMSettingsRow(
                icon: "rectangle.split.3x1.fill",
                iconBackground: MMColor.primary
            ) {
                MMSettingsLabel(title: "Split style")
                Spacer(minLength: 8)
                Picker("Split style", selection: Binding(
                    get: { profile.splitStyle },
                    set: { newValue in
                        guard newValue != profile.splitStyle else { return }
                        profile.splitStyle = newValue
                        profile.updatedAt = Date()
                        showRegenerateAlert = true
                    }
                )) {
                    ForEach(SplitStyle.allCases, id: \.self) { style in
                        Text(style.displayName).tag(style)
                    }
                }
                .pickerStyle(.menu)
                .tint(MMColor.primary)
            }

            MMSettingsRow(
                icon: "calendar",
                iconBackground: MMColor.secondary
            ) {
                MMSettingsLabel(title: "Days per week")
                Spacer(minLength: 8)
                Stepper(value: Binding(
                    get: { profile.daysPerWeek },
                    set: { newValue in
                        guard newValue != profile.daysPerWeek else { return }
                        profile.daysPerWeek = newValue
                        profile.updatedAt = Date()
                        showRegenerateAlert = true
                    }
                ), in: 1...7) {
                    Text("\(profile.daysPerWeek)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(MMColor.textPrimary)
                        .monospacedDigit()
                }
                .labelsHidden()
                .tint(MMColor.primary)
            }

            MMSettingsRow(
                icon: "clock.fill",
                iconBackground: Color(.sRGB, red: 0.475, green: 0.647, blue: 0.722, opacity: 1)
            ) {
                MMSettingsLabel(title: "Session length")
                Spacer(minLength: 8)
                Stepper(value: $profile.sessionLengthMinutes, in: 15...90, step: 5) {
                    Text("\(profile.sessionLengthMinutes) min")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(MMColor.textPrimary)
                        .monospacedDigit()
                }
                .labelsHidden()
                .tint(MMColor.primary)
            }

            NavigationLink {
                EditScheduleView(profile: profile)
            } label: {
                MMSettingsRow(
                    icon: "calendar.badge.clock",
                    iconBackground: MMColor.primary,
                    isLast: true
                ) {
                    MMSettingsLabel(title: "Edit weekly schedule",
                                    subtitle: "Choose a category for each day")
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(MMColor.textTertiary)
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Equipment

    private var equipmentSection: some View {
        MMSettingsSection(
            title: "Equipment available",
            footer: "Only workouts that fit your equipment are shown."
        ) {
            ForEach(Array(Equipment.allCases.enumerated()), id: \.element) { index, equipment in
                Button {
                    toggleEquipment(equipment)
                } label: {
                    let isSelected = profile.availableEquipment.contains(equipment)
                    MMSettingsRow(
                        icon: nil,
                        iconBackground: .clear,
                        isLast: index == Equipment.allCases.count - 1
                    ) {
                        MMSettingsLabel(title: equipment.displayName)
                        Spacer(minLength: 8)
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(MMColor.primary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        MMSettingsSection(title: "About") {
            MMSettingsRow(
                icon: "info.circle.fill",
                iconBackground: MMColor.textSecondary
            ) {
                MMSettingsLabel(title: "Version")
                Spacer(minLength: 8)
                Text("1.0 · Morning Light")
                    .font(MMFont.callout)
                    .foregroundStyle(MMColor.textTertiary)
            }

            MMSettingsRow(
                icon: "heart.fill",
                iconBackground: MMColor.error,
                isLast: true
            ) {
                MMSettingsLabel(title: "Member since")
                Spacer(minLength: 8)
                Text(profile.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(MMFont.callout)
                    .foregroundStyle(MMColor.textTertiary)
            }
        }
    }

    // MARK: - Footer

    private var affirmationFooter: some View {
        VStack(spacing: 14) {
            Text("You are not a product here.\nJust a person, showing up.")
                .font(MMFont.quote)
                .foregroundStyle(MMColor.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 24)
            Text("Made with care · \(Calendar.current.component(.year, from: Date()).description)")
                .font(MMFont.caption1)
                .foregroundStyle(MMColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
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
        }
        Button("Keep current", role: .cancel) {}
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

// MARK: - Section + row primitives

struct MMSettingsSection<Content: View>: View {
    let title: String
    var footer: String? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .tracking(0.6)
                .foregroundStyle(MMColor.textTertiary)
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(MMColor.surfaceCard)
            )
            .mmShadow(.xs)

            if let footer {
                Text(footer)
                    .font(MMFont.footnote)
                    .foregroundStyle(MMColor.textTertiary)
                    .padding(.horizontal, 16)
                    .padding(.top, 2)
            }
        }
    }
}

struct MMSettingsRow<Content: View>: View {
    var icon: String?
    var iconBackground: Color = MMColor.primary
    var isLast: Bool = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                if let icon {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(iconBackground)
                            .frame(width: 30, height: 30)
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                content()
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 14)

            if !isLast {
                Rectangle()
                    .fill(MMColor.separator)
                    .frame(height: 0.5)
                    .padding(.leading, icon == nil ? 14 : 56)
            }
        }
    }
}

struct MMSettingsLabel: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(MMFont.callout)
                .foregroundStyle(MMColor.textPrimary)
            if let subtitle {
                Text(subtitle)
                    .font(MMFont.caption1)
                    .foregroundStyle(MMColor.textTertiary)
                    .lineLimit(2)
            }
        }
    }
}
