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
import SwiftData
import UserNotifications

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @Environment(ErrorPresenter.self) private var errorPresenter
    @Bindable var profile: UserProfile

    @State private var showRegenerateAlert: Bool = false
    @State private var showResetAlert: Bool = false
    @State private var showNotificationsDeniedAlert: Bool = false
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var pendingSplit: SplitStyle?
    @State private var pendingDays: Int?

    var body: some View {
        NavigationStack {
            Form {
                prefsSection
                planSection
                equipmentSection
                notificationsSection
                aboutSection
                dangerSection
            }
            .navigationTitle("Settings")
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

    // MARK: - Notifications

    private var notificationsSection: some View {
        Section {
            Toggle("Daily workout reminder", isOn: Binding(
                get: { profile.notificationsEnabled },
                set: { newValue in toggleDailyReminder(newValue) }
            ))
            .disabled(notificationStatus == .denied)

            if profile.notificationsEnabled && notificationStatus != .denied {
                DatePicker(
                    "Remind me at",
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
            }

            Toggle("Weekly check-in reminder", isOn: Binding(
                get: { profile.weeklyCheckinEnabled },
                set: { newValue in toggleWeeklyCheckin(newValue) }
            ))
            .disabled(notificationStatus == .denied)
        } header: {
            Text("Notifications")
        } footer: {
            if notificationStatus == .denied {
                Text("Notifications are turned off for MotivateMe in the system Settings app.")
            } else {
                Text("We'll nudge you at your reminder time on workout days and once a week for the check-in.")
            }
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Member since")
                Spacer()
                Text(profile.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("Version")
                Spacer()
                Text(appVersionString)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Button {
                sendFeedback()
            } label: {
                HStack {
                    Text("Send feedback")
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "envelope")
                        .foregroundStyle(.secondary)
                }
            }

            Button {
                openPrivacyPolicy()
            } label: {
                HStack {
                    Text("Privacy policy")
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("About")
        }
    }

    // MARK: - Danger zone

    private var dangerSection: some View {
        Section {
            Button(role: .destructive) {
                showResetAlert = true
            } label: {
                Text("Start over")
            }
        } footer: {
            Text("Erases your profile and every workout, check-in, and measurement stored on this device.")
        }
    }

    // MARK: - Derived

    private var appVersionString: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "—"
        let build = info?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
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
