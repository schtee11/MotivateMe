//
//  LibraryStore.swift
//  MotivateMe
//
//  In-memory cache for bundled library data (Exercise, WorkoutTemplate).
//  Loaded once at app launch from JSON files in the app bundle. Kept out of
//  SwiftData so that every user's iCloud doesn't duplicate immutable library
//  data. Lookups are by UUID, matching the ID-based references on Session
//  and SessionExercise.
//

import Foundation

final class LibraryStore {
    static let shared = LibraryStore()

    private(set) var exercises: [UUID: Exercise] = [:]
    private(set) var workoutTemplates: [UUID: WorkoutTemplate] = [:]

    private init() {}

    /// Load both JSON files from the app bundle. Call once at app launch.
    /// Missing or malformed files log to console and leave the store empty;
    /// callers downstream must handle empty-library cases gracefully.
    func load() {
        exercises = Dictionary(
            uniqueKeysWithValues: decodeArray("exercises", as: Exercise.self).map { ($0.id, $0) }
        )
        workoutTemplates = Dictionary(
            uniqueKeysWithValues: decodeArray("workoutTemplates", as: WorkoutTemplate.self).map { ($0.id, $0) }
        )
    }

    func exercise(id: UUID) -> Exercise? { exercises[id] }
    func workoutTemplate(id: UUID) -> WorkoutTemplate? { workoutTemplates[id] }

    private func decodeArray<T: Decodable>(_ fileName: String, as: T.Type) -> [T] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("LibraryStore: \(fileName).json missing from bundle")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            print("LibraryStore: failed to decode \(fileName).json: \(error)")
            return []
        }
    }
}
