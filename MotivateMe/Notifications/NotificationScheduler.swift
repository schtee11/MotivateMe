//
//  NotificationScheduler.swift
//  MotivateMe
//
//  Wraps UNUserNotificationCenter for the two reminders the app schedules:
//  a daily workout nudge at `UserProfile.reminderTime` and a weekly
//  check-in nudge. Kept as a plain enum of async static methods — there is
//  no per-instance state, and the system center is the real owner.
//
//  Every scheduling call first cancels the matching id and reschedules, so
//  callers can invoke `sync(profile:)` after any relevant setting changes
//  without worrying about duplicates.
//

import Foundation
import OSLog
import UserNotifications

enum NotificationScheduler {
    private static let log = Logger(subsystem: "com.williamtrout.MotivateMe", category: "notifications")

    enum Identifier {
        static let dailyWorkout = "com.williamtrout.MotivateMe.notification.dailyWorkout"
        static let weeklyCheckin = "com.williamtrout.MotivateMe.notification.weeklyCheckin"
    }

    /// Asks the user for notification permission. Returns the effective
    /// authorization status after the prompt resolves (or without prompting
    /// if the user already made a decision).
    static func requestAuthorization() async -> UNAuthorizationStatus {
        let center = UNUserNotificationCenter.current()
        let current = await center.notificationSettings().authorizationStatus
        switch current {
        case .notDetermined:
            do {
                _ = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                log.error("authorization request failed: \(error.localizedDescription, privacy: .public)")
            }
            return await center.notificationSettings().authorizationStatus
        default:
            return current
        }
    }

    static func currentStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    /// Reconcile the scheduled notifications with the profile's current
    /// settings. Cancels anything we no longer want, reschedules the rest.
    /// Safe to call redundantly — each reminder is keyed by a stable id.
    static func sync(profile: UserProfile) async {
        let center = UNUserNotificationCenter.current()
        let status = await center.notificationSettings().authorizationStatus
        guard status == .authorized || status == .provisional else {
            center.removePendingNotificationRequests(withIdentifiers: [
                Identifier.dailyWorkout,
                Identifier.weeklyCheckin
            ])
            return
        }

        if profile.notificationsEnabled {
            scheduleDailyWorkout(at: profile.reminderTime)
        } else {
            center.removePendingNotificationRequests(withIdentifiers: [Identifier.dailyWorkout])
        }

        if profile.weeklyCheckinEnabled {
            scheduleWeeklyCheckin()
        } else {
            center.removePendingNotificationRequests(withIdentifiers: [Identifier.weeklyCheckin])
        }
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            Identifier.dailyWorkout,
            Identifier.weeklyCheckin
        ])
    }

    private static func scheduleDailyWorkout(at reminderTime: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let content = UNMutableNotificationContent()
        content.title = "Time to move"
        content.body = "Log today's workout or tap to see what's on the plan."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: Identifier.dailyWorkout,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                log.error("daily reminder schedule failed: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    private static func scheduleWeeklyCheckin() {
        // Sunday 9am — a low-pressure moment to reflect on the week.
        var components = DateComponents()
        components.weekday = 1
        components.hour = 9
        components.minute = 0

        let content = UNMutableNotificationContent()
        content.title = "Weekly check-in"
        content.body = "How did last week feel? Take a moment to log it."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: Identifier.weeklyCheckin,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                log.error("weekly check-in schedule failed: \(error.localizedDescription, privacy: .public)")
            }
        }
    }
}
