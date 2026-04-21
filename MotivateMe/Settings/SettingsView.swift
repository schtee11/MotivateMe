//
//  SettingsView.swift
//  MotivateMe
//
//  Morning Light settings. Grouped-inset list with colored icon tiles,
//  gentle micro-copy, a featured "gentle part" section with the ethos
//  quote, and an affirmation footer. Preferences are stored in AppStorage
//  (keys prefixed `mm.`) and each toggle is wired to a concrete behavior
//  elsewhere in the app — nothing here is cosmetic.
//
//  Changing split or daysPerWeek still offers the one-tap schedule
//  regeneration alert.
//

import SwiftUI
import SwiftData
import UIKit
import UserNotifications

struct ExportDocument: Identifiable {
    let id = UUID()
    let url: URL
}

struct ExportShareSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @Environment(ErrorPresenter.self) private var errorPresenter
    @Bindable var profile: UserProfile

    @State private var showRegenerateAlert: Bool = false
    @State private var showResetAlert: Bool = false
    @State private var showNotificationsDeniedAlert: Bool = false
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var editingName: Bool = false

    // UI-only preferences (see note in file header).
    @AppStorage("mm.userName") private var userName: String = ""
    @AppStorage("mm.hideStreakNumbers") private var hideStreakNumbers: Bool = false
    @AppStorage("mm.forgivenessWindow") private var forgivenessWindow: Int = 3
    @AppStorage("mm.quietMode") private var quietMode: Bool = false
    @AppStorage("mm.appearance") private var appearancePref: String = "auto"
    @AppStorage("mm.serifAccents") private var serifAccents: Bool = true
    @AppStorage("mm.reduceMotion") private var reduceMotion: Bool = false

    @State private var exportDocument: ExportDocument?
    @State private var showExportError: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                headerCopy
                profileSection
                checkinsSection
                gentleSection
                planSection
                equipmentSection
                appearanceSection
                dataSection
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
        .task { notificationStatus = await NotificationScheduler.currentStatus() }
        .alert(
            "Regenerate schedule?",
            isPresented: $showRegenerateAlert,
            actions: regenerateActions,
            message: { Text("Your weekly plan changed. Regenerate workout days to match? Your custom edits will be replaced.") }
        )
        .alert("Start over?", isPresented: $showResetAlert) {
            Button("Erase everything", role: .destructive) { resetAllData() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This deletes your profile, workouts, check-ins, and measurements. The app will restart onboarding.")
        }
        .alert("Notifications are off", isPresented: $showNotificationsDeniedAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            Button("Not now", role: .cancel) {}
        } message: {
            Text("Enable notifications for MotivateMe in the system Settings app to receive reminders.")
        }
        .sheet(isPresented: $editingName) {
            NameEditSheet(initial: userName) { newValue in
                userName = newValue
                editingName = false
            } onCancel: {
                editingName = false
            }
            .presentationDetents([.height(260)])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $exportDocument) { doc in
            ExportShareSheet(url: doc.url)
        }
        .alert("Couldn't export", isPresented: $showExportError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Something went wrong while preparing your export. Please try again.")
        }
    }

    private var headerCopy: some View {
        Text("A handful of switches. That's all.")
            .font(MMFont.subhead)
            .foregroundStyle(MMColor.textSecondary)
            .padding(.horizontal, 4)
    }

    // MARK: - Profile

    private var profileSection: some View {
        MMSettingsSection(title: "Profile") {
            Button {
                editingName = true
            } label: {
                MMSettingsRow(icon: "person.fill", iconBackground: MMColor.primary) {
                    MMSettingsLabel(title: "Name")
                    Spacer(minLength: 8)
                    Text(userName.isEmpty ? "Add" : userName)
                        .font(MMFont.callout)
                        .foregroundStyle(MMColor.textTertiary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(MMColor.textTertiary)
                }
            }
            .buttonStyle(.plain)

            MMSettingsRow(icon: "figure.flexibility", iconBackground: MMColor.secondary) {
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

            MMSettingsRow(
                icon: "scalemass.fill",
                iconBackground: Color(.sRGB, red: 0.478, green: 0.647, blue: 0.722, opacity: 1)
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
                icon: "sun.max.fill",
                iconBackground: Color(.sRGB, red: 0.909, green: 0.608, blue: 0.243, opacity: 1),
                isLast: true
            ) {
                MMSettingsLabel(title: "Rhythm", subtitle: "When you prefer to show up")
                Spacer(minLength: 8)
                Text(rhythmLabel)
                    .font(MMFont.callout)
                    .foregroundStyle(MMColor.textTertiary)
            }
        }
    }

    private var rhythmLabel: String {
        let hour = Calendar.current.component(.hour, from: profile.reminderTime)
        switch hour {
        case 4..<11:  return "Mornings"
        case 11..<17: return "Afternoons"
        default:      return "Evenings"
        }
    }

    // MARK: - Check-ins & reminders

    private var checkinsSection: some View {
        MMSettingsSection(
            title: "Check-ins & reminders",
            footer: checkinsFooter
        ) {
            MMSettingsRow(
                icon: "bell.fill",
                iconBackground: Color(.sRGB, red: 0.851, green: 0.459, blue: 0.341, opacity: 1)
            ) {
                MMSettingsLabel(title: "Morning check-in",
                                subtitle: "A one-minute start to your day")
                Spacer(minLength: 8)
                Toggle("", isOn: $profile.morningSelfReportEnabled)
                    .labelsHidden()
                    .tint(Color(.sRGB, red: 0.204, green: 0.780, blue: 0.349, opacity: 1))
            }

            MMSettingsRow(
                icon: "clock.fill",
                iconBackground: Color(.sRGB, red: 0.478, green: 0.647, blue: 0.722, opacity: 1)
            ) {
                MMSettingsLabel(title: "Habit reminders",
                                subtitle: "For the days you planned")
                Spacer(minLength: 8)
                Toggle("", isOn: Binding(
                    get: { profile.notificationsEnabled },
                    set: { newValue in toggleDailyReminder(newValue) }
                ))
                .labelsHidden()
                .disabled(notificationStatus == .denied)
                .tint(Color(.sRGB, red: 0.204, green: 0.780, blue: 0.349, opacity: 1))
            }

            if profile.notificationsEnabled && notificationStatus != .denied {
                MMSettingsRow(
                    icon: "alarm.fill",
                    iconBackground: Color(.sRGB, red: 0.435, green: 0.420, blue: 0.710, opacity: 1)
                ) {
                    MMSettingsLabel(title: "Remind me at")
                    Spacer(minLength: 8)
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { profile.reminderTime },
                            set: { newValue in
                                profile.reminderTime = newValue
                                profile.updatedAt = Date()
                                Task { await NotificationScheduler.sync(profile: profile) }
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }
            }

            MMSettingsRow(
                icon: "calendar.badge.checkmark",
                iconBackground: MMColor.secondary,
                isLast: true
            ) {
                MMSettingsLabel(title: "Weekly check-in",
                                subtitle: "A Sunday look-back, if you want one")
                Spacer(minLength: 8)
                Toggle("", isOn: Binding(
                    get: { profile.weeklyCheckinEnabled },
                    set: { newValue in toggleWeeklyCheckin(newValue) }
                ))
                .labelsHidden()
                .disabled(notificationStatus == .denied)
                .tint(Color(.sRGB, red: 0.204, green: 0.780, blue: 0.349, opacity: 1))
            }
        }
    }

    private var checkinsFooter: String {
        if notificationStatus == .denied {
            return "Notifications are turned off for MotivateMe in the system Settings app."
        }
        return "Notifications are gentle by default — one a day, plus the ones you set."
    }

    // MARK: - The gentle part

    private var gentleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                MMEyebrow(text: "The gentle part")
                Circle()
                    .fill(MMColor.secondary)
                    .frame(width: 3, height: 3)
                Text("the ethos, in switches")
                    .font(.system(size: 11, weight: .regular, design: .serif).italic())
                    .foregroundStyle(MMColor.secondary)
            }
            .padding(.horizontal, 16)

            VStack(spacing: 0) {
                gentleQuote
                Divider().background(MMColor.separator)

                MMSettingsRow(
                    icon: "flame.fill",
                    iconBackground: Color(.sRGB, red: 0.909, green: 0.608, blue: 0.243, opacity: 1)
                ) {
                    MMSettingsLabel(title: "Hide streak numbers",
                                    subtitle: "You'll still see progress — without the counter")
                    Spacer(minLength: 8)
                    Toggle("", isOn: $hideStreakNumbers)
                        .labelsHidden()
                        .tint(Color(.sRGB, red: 0.204, green: 0.780, blue: 0.349, opacity: 1))
                }

                forgivenessRow

                MMSettingsRow(
                    icon: "moon.fill",
                    iconBackground: Color(.sRGB, red: 0.435, green: 0.420, blue: 0.710, opacity: 1),
                    isLast: true
                ) {
                    MMSettingsLabel(title: "Quiet mode",
                                    subtitle: "Dim stats, numbers, and comparisons for a while")
                    Spacer(minLength: 8)
                    Toggle("", isOn: $quietMode)
                        .labelsHidden()
                        .tint(Color(.sRGB, red: 0.204, green: 0.780, blue: 0.349, opacity: 1))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [MMColor.secondaryTint, MMColor.surfaceCard],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(MMColor.border, lineWidth: 0.5)
            )

            Text("These are the ones we're most proud of.")
                .font(.system(size: 13, weight: .regular, design: .serif).italic())
                .foregroundStyle(MMColor.textTertiary)
                .padding(.horizontal, 16)
                .padding(.top, 2)
        }
    }

    private var gentleQuote: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\u{201C}")
                .font(.system(size: 36, weight: .regular, design: .serif).italic())
                .foregroundStyle(MMColor.secondary)
                .offset(y: 2)
            Text("Missing days is part of life, not a failure. These switches decide how we respond.")
                .font(.system(size: 15, weight: .regular, design: .serif).italic())
                .foregroundStyle(MMColor.textPrimary)
                .lineSpacing(3)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    private var forgivenessRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(.sRGB, red: 0.545, green: 0.655, blue: 0.420, opacity: 1))
                    .frame(width: 30, height: 30)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text("Forgiveness window")
                        .font(MMFont.callout)
                        .foregroundStyle(MMColor.textPrimary)
                    Text("Days you can miss before anything changes")
                        .font(MMFont.caption1)
                        .foregroundStyle(MMColor.textTertiary)
                }
                Spacer(minLength: 8)
                Text("\(forgivenessWindow) \(forgivenessWindow == 1 ? "day" : "days")")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(MMColor.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(MMColor.primaryTint))
            }

            Slider(
                value: Binding(
                    get: { Double(forgivenessWindow) },
                    set: { forgivenessWindow = Int($0.rounded()) }
                ),
                in: 0...7,
                step: 1
            )
            .tint(MMColor.primary)

            HStack {
                Text("Strict")
                Spacer()
                Text("Balanced")
                Spacer()
                Text("Forgiving")
            }
            .font(MMFont.caption2)
            .foregroundStyle(MMColor.textTertiary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .overlay(
            Rectangle()
                .fill(MMColor.separator)
                .frame(height: 0.5)
                .padding(.leading, 14),
            alignment: .top
        )
    }

    // MARK: - Plan

    private var planSection: some View {
        MMSettingsSection(
            title: "Your plan",
            footer: "Changing split or days offers a one-tap schedule regeneration."
        ) {
            MMSettingsRow(icon: "rectangle.split.3x1.fill", iconBackground: MMColor.primary) {
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

            MMSettingsRow(icon: "calendar", iconBackground: MMColor.secondary) {
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
                icon: "timer",
                iconBackground: Color(.sRGB, red: 0.478, green: 0.647, blue: 0.722, opacity: 1)
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

    // MARK: - Derived

    private var appVersionString: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "—"
        let build = info?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        MMSettingsSection(title: "Appearance") {
            MMSettingsRow(
                icon: "sun.max.fill",
                iconBackground: Color(.sRGB, red: 0.909, green: 0.608, blue: 0.243, opacity: 1)
            ) {
                MMSettingsLabel(title: "Theme")
                Spacer(minLength: 8)
                Picker("Theme", selection: $appearancePref) {
                    Text("Light").tag("light")
                    Text("Auto").tag("auto")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(.segmented)
                .fixedSize()
            }

            MMSettingsRow(icon: "pencil", iconBackground: MMColor.primary) {
                MMSettingsLabel(title: "Serif accents",
                                subtitle: "The soft italic touch on key moments")
                Spacer(minLength: 8)
                Toggle("", isOn: $serifAccents)
                    .labelsHidden()
                    .tint(Color(.sRGB, red: 0.204, green: 0.780, blue: 0.349, opacity: 1))
            }

            MMSettingsRow(
                icon: "circle.fill",
                iconBackground: Color(.sRGB, red: 0.627, green: 0.545, blue: 0.710, opacity: 1),
                isLast: true
            ) {
                MMSettingsLabel(title: "Reduce motion")
                Spacer(minLength: 8)
                Toggle("", isOn: $reduceMotion)
                    .labelsHidden()
                    .tint(Color(.sRGB, red: 0.204, green: 0.780, blue: 0.349, opacity: 1))
            }
        }
    }

    // MARK: - Your data

    private var dataSection: some View {
        MMSettingsSection(
            title: "Your data",
            footer: "Everything stays on this device. Export shares a JSON copy you control."
        ) {
            Button {
                prepareExport()
            } label: {
                MMSettingsRow(
                    icon: "square.and.arrow.up",
                    iconBackground: Color(.sRGB, red: 0.545, green: 0.655, blue: 0.420, opacity: 1)
                ) {
                    MMSettingsLabel(title: "Export your data",
                                    subtitle: "A JSON copy of your profile, sessions, and check-ins")
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(MMColor.textTertiary)
                }
            }
            .buttonStyle(.plain)

            Button {
                showResetAlert = true
            } label: {
                MMSettingsRow(
                    icon: "trash.fill",
                    iconBackground: Color(.sRGB, red: 0.769, green: 0.353, blue: 0.353, opacity: 1),
                    isLast: true
                ) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Delete everything")
                            .font(MMFont.callout)
                            .foregroundStyle(Color(.sRGB, red: 0.769, green: 0.353, blue: 0.353, opacity: 1))
                        Text("Fully and permanently — no 30-day recovery")
                            .font(MMFont.caption1)
                            .foregroundStyle(MMColor.textTertiary)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(MMColor.textTertiary)
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        MMSettingsSection(title: "About") {
            MMSettingsRow(
                icon: "info.circle.fill",
                iconBackground: Color(.sRGB, red: 0.604, green: 0.580, blue: 0.533, opacity: 1)
            ) {
                MMSettingsLabel(title: "Version")
                Spacer(minLength: 8)
                Text(appVersionString)
                    .font(MMFont.callout)
                    .foregroundStyle(MMColor.textTertiary)
                    .monospacedDigit()
            }

            Button {
                sendFeedback()
            } label: {
                MMSettingsRow(icon: "envelope.fill", iconBackground: MMColor.secondary) {
                    MMSettingsLabel(title: "Send feedback")
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(MMColor.textTertiary)
                }
            }
            .buttonStyle(.plain)

            Button {
                openPrivacyPolicy()
            } label: {
                MMSettingsRow(
                    icon: "leaf.fill",
                    iconBackground: Color(.sRGB, red: 0.545, green: 0.655, blue: 0.420, opacity: 1)
                ) {
                    MMSettingsLabel(title: "Privacy \u{00B7} Terms")
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(MMColor.textTertiary)
                }
            }
            .buttonStyle(.plain)

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

    private func toggleDailyReminder(_ newValue: Bool) {
        handleNotificationToggle(enable: newValue) { status in
            profile.notificationsEnabled = newValue && status != .denied
            profile.updatedAt = Date()
            Task { await NotificationScheduler.sync(profile: profile) }
        }
    }

    private func toggleWeeklyCheckin(_ newValue: Bool) {
        handleNotificationToggle(enable: newValue) { status in
            profile.weeklyCheckinEnabled = newValue && status != .denied
            profile.updatedAt = Date()
            Task { await NotificationScheduler.sync(profile: profile) }
        }
    }

    // Turning a notification preference on requires asking the system; if
    // the user previously denied, surface that so they can flip it in
    // Settings.app rather than silently leaving the toggle in a dead state.
    private func handleNotificationToggle(enable: Bool, apply: @escaping (UNAuthorizationStatus) -> Void) {
        guard enable else {
            apply(notificationStatus)
            return
        }
        Task {
            let status = await NotificationScheduler.requestAuthorization()
            await MainActor.run {
                notificationStatus = status
                if status == .denied {
                    showNotificationsDeniedAlert = true
                }
                apply(status)
            }
        }
    }

    // MARK: - URLs / feedback / reset

    private func openPrivacyPolicy() {
        guard let url = URL(string: "https://williamtrout.com/motivateme/privacy") else { return }
        openURL(url)
    }

    private func sendFeedback() {
        let subject = "MotivateMe feedback (v\(appVersionString))"
        let encoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "mailto:feedback@williamtrout.com?subject=\(encoded)") else { return }
        openURL(url)
    }

    private func prepareExport() {
        do {
            let url = try DataExport.makeExportFile(context: modelContext)
            exportDocument = ExportDocument(url: url)
        } catch {
            errorPresenter.present(error, context: "Exporting your data")
            showExportError = true
        }
    }

    private func resetAllData() {
        NotificationScheduler.cancelAll()
        WorkoutDraftStore.clear()
        do {
            try modelContext.delete(model: UserProfile.self)
            try modelContext.delete(model: Session.self)
            try modelContext.delete(model: SessionExercise.self)
            try modelContext.delete(model: DailyCheckin.self)
            try modelContext.delete(model: BodyMeasurement.self)
            try modelContext.save()
        } catch {
            errorPresenter.present(error, context: "Erasing your data")
        }
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

// MARK: - Name edit sheet

private struct NameEditSheet: View {
    let initial: String
    let onSave: (String) -> Void
    let onCancel: () -> Void

    @State private var value: String = ""
    @FocusState private var focused: Bool

    init(initial: String, onSave: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
        self.initial = initial
        self.onSave = onSave
        self.onCancel = onCancel
        _value = State(initialValue: initial)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Your name")
                    .font(MMFont.title3)
                    .foregroundStyle(MMColor.textPrimary)
                Text("However you'd like to be greeted.")
                    .font(MMFont.footnote)
                    .foregroundStyle(MMColor.textSecondary)
            }
            .padding(.top, 4)

            TextField("Name", text: $value)
                .textInputAutocapitalization(.words)
                .focused($focused)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(MMColor.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(MMColor.surfaceCard)
                )
                .mmShadow(.xs)
                .submitLabel(.done)
                .onSubmit { onSave(trimmed) }

            Button {
                onSave(trimmed)
            } label: {
                Text("Save")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(MMColor.primary))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .background(MMColor.bg.ignoresSafeArea())
        .onAppear { focused = true }
    }

    private var trimmed: String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
