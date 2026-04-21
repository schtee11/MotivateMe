//
//  DataExport.swift
//  MotivateMe
//
//  Serializes the user's SwiftData records to a portable JSON document and
//  writes it to a temporary file for sharing via the system share sheet.
//  Everything the user has entered or generated is captured: profile,
//  sessions (with per-exercise sets), daily check-ins, body measurements,
//  and journal entries.
//

import Foundation
import SwiftData

enum DataExport {
    struct Payload: Encodable {
        var exportedAt: Date
        var schemaVersion: Int
        var profile: ProfilePayload?
        var sessions: [SessionPayload]
        var checkins: [CheckinPayload]
        var measurements: [MeasurementPayload]
        var journalEntries: [JournalPayload]
    }

    struct ProfilePayload: Encodable {
        var id: UUID
        var createdAt: Date
        var updatedAt: Date
        var goals: [String]
        var experienceLevel: String
        var splitStyle: String
        var daysPerWeek: Int
        var availableEquipment: [String]
        var sessionLengthMinutes: Int
        var weeklySchedule: [ScheduleEntryPayload]
        var contraindications: [String]
        var preferredUnit: String
        var notificationsEnabled: Bool
        var reminderTime: Date
        var weeklyCheckinEnabled: Bool
        var morningSelfReportEnabled: Bool
    }

    struct ScheduleEntryPayload: Encodable {
        var weekday: String
        var templateCategory: String?
    }

    struct SessionPayload: Encodable {
        var id: UUID
        var date: Date
        var completedAt: Date?
        var workoutTemplateId: UUID?
        var status: String
        var durationSeconds: Int?
        var effortRating: Int?
        var notes: String?
        var readinessScoreSnapshot: Int?
        var readinessSource: String
        var prExerciseIds: [UUID]
        var exercises: [SessionExercisePayload]
    }

    struct SessionExercisePayload: Encodable {
        var id: UUID
        var exerciseId: UUID
        var order: Int
        var skipped: Bool
        var effortFeedback: String?
        var sets: [SetPayload]
    }

    struct SetPayload: Encodable {
        var setNumber: Int
        var reps: Int?
        var durationSeconds: Int?
        var weight: Double?
        var completed: Bool
    }

    struct CheckinPayload: Encodable {
        var id: UUID
        var date: Date
        var isCommitmentDay: Bool
        var status: String
        var sessionId: UUID?
        var readinessScore: Int?
        var readinessSource: String
        var hrvSnapshot: Double?
        var rhrSnapshot: Double?
        var sleepHoursSnapshot: Double?
        var selfReportedEnergy: String?
    }

    struct MeasurementPayload: Encodable {
        var id: UUID
        var date: Date
        var type: String
        var value: Double
        var unit: String
    }

    struct JournalPayload: Encodable {
        var id: UUID
        var date: Date
        var mood: String
        var title: String
        var body: String
        var prompt: String
        var grateful: String
    }

    /// Fetches everything and returns a URL to a temp JSON file suitable for
    /// sharing. The file is written fresh on every call with a timestamped
    /// filename so the share sheet's suggested name is readable.
    @MainActor
    static func makeExportFile(context: ModelContext) throws -> URL {
        let profile = try UserProfile.current(in: context)
        let sessions = try context.fetch(FetchDescriptor<Session>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        ))
        let checkins = try context.fetch(FetchDescriptor<DailyCheckin>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        ))
        let measurements = try context.fetch(FetchDescriptor<BodyMeasurement>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        ))
        let journal = try context.fetch(FetchDescriptor<JournalEntry>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        ))

        let payload = Payload(
            exportedAt: Date(),
            schemaVersion: 1,
            profile: profile.map { makeProfilePayload($0) },
            sessions: sessions.map { makeSessionPayload($0) },
            checkins: checkins.map { makeCheckinPayload($0) },
            measurements: measurements.map { makeMeasurementPayload($0) },
            journalEntries: journal.map { makeJournalPayload($0) }
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let stamp = formatter.string(from: Date())
        let filename = "MotivateMe-\(stamp).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try data.write(to: url, options: .atomic)
        return url
    }

    private static func makeProfilePayload(_ p: UserProfile) -> ProfilePayload {
        ProfilePayload(
            id: p.id,
            createdAt: p.createdAt,
            updatedAt: p.updatedAt,
            goals: p.goals.map { $0.rawValue },
            experienceLevel: p.experienceLevel.rawValue,
            splitStyle: p.splitStyle.rawValue,
            daysPerWeek: p.daysPerWeek,
            availableEquipment: p.availableEquipment.map { $0.rawValue },
            sessionLengthMinutes: p.sessionLengthMinutes,
            weeklySchedule: p.weeklySchedule.map {
                ScheduleEntryPayload(
                    weekday: $0.weekday.rawValue,
                    templateCategory: $0.templateCategory?.rawValue
                )
            },
            contraindications: p.contraindications.map { $0.rawValue },
            preferredUnit: p.preferredUnit.rawValue,
            notificationsEnabled: p.notificationsEnabled,
            reminderTime: p.reminderTime,
            weeklyCheckinEnabled: p.weeklyCheckinEnabled,
            morningSelfReportEnabled: p.morningSelfReportEnabled
        )
    }

    private static func makeSessionPayload(_ s: Session) -> SessionPayload {
        let exercises = (s.sessionExercises ?? []).sorted { $0.order < $1.order }
        return SessionPayload(
            id: s.id,
            date: s.date,
            completedAt: s.completedAt,
            workoutTemplateId: s.workoutTemplateId,
            status: s.status.rawValue,
            durationSeconds: s.durationSeconds,
            effortRating: s.effortRating,
            notes: s.notes,
            readinessScoreSnapshot: s.readinessScoreSnapshot,
            readinessSource: s.readinessSource.rawValue,
            prExerciseIds: s.prExerciseIds,
            exercises: exercises.map { makeSessionExercisePayload($0) }
        )
    }

    private static func makeSessionExercisePayload(_ e: SessionExercise) -> SessionExercisePayload {
        SessionExercisePayload(
            id: e.id,
            exerciseId: e.exerciseId,
            order: e.order,
            skipped: e.skipped,
            effortFeedback: e.effortFeedback,
            sets: e.sets.map {
                SetPayload(
                    setNumber: $0.setNumber,
                    reps: $0.reps,
                    durationSeconds: $0.durationSeconds,
                    weight: $0.weight,
                    completed: $0.completed
                )
            }
        )
    }

    private static func makeCheckinPayload(_ c: DailyCheckin) -> CheckinPayload {
        CheckinPayload(
            id: c.id,
            date: c.date,
            isCommitmentDay: c.isCommitmentDay,
            status: c.status.rawValue,
            sessionId: c.sessionId,
            readinessScore: c.readinessScore,
            readinessSource: c.readinessSource.rawValue,
            hrvSnapshot: c.hrvSnapshot,
            rhrSnapshot: c.rhrSnapshot,
            sleepHoursSnapshot: c.sleepHoursSnapshot,
            selfReportedEnergy: c.selfReportedEnergy
        )
    }

    private static func makeMeasurementPayload(_ m: BodyMeasurement) -> MeasurementPayload {
        MeasurementPayload(
            id: m.id,
            date: m.date,
            type: m.type,
            value: m.value,
            unit: m.unit.rawValue
        )
    }

    private static func makeJournalPayload(_ j: JournalEntry) -> JournalPayload {
        JournalPayload(
            id: j.id,
            date: j.date,
            mood: j.mood.rawValue,
            title: j.title,
            body: j.body,
            prompt: j.prompt,
            grateful: j.grateful
        )
    }
}
