//
//  JournalEntry.swift
//  MotivateMe
//
//  SwiftData model for a single journal entry. Stored on-device only,
//  matching the design's "kept on this device" promise. Mood is one of
//  five Apple-style chips; title and gratitude are optional.
//

import Foundation
import SwiftData

enum JournalMood: String, Codable, CaseIterable, Hashable {
    case great, good, okay, tired, low

    var emoji: String {
        switch self {
        case .great: return "😄"
        case .good:  return "🙂"
        case .okay:  return "😐"
        case .tired: return "😪"
        case .low:   return "🌧️"
        }
    }

    var label: String {
        switch self {
        case .great: return "Great"
        case .good:  return "Good"
        case .okay:  return "Okay"
        case .tired: return "Tired"
        case .low:   return "Low"
        }
    }
}

@Model
final class JournalEntry {
    var id: UUID = UUID()
    var date: Date = Date()
    var moodRaw: String = JournalMood.okay.rawValue
    var title: String = ""
    var body: String = ""
    var prompt: String = ""
    var grateful: String = ""

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        mood: JournalMood = .okay,
        title: String = "",
        body: String = "",
        prompt: String = "",
        grateful: String = ""
    ) {
        self.id = id
        self.date = date
        self.moodRaw = mood.rawValue
        self.title = title
        self.body = body
        self.prompt = prompt
        self.grateful = grateful
    }

    var mood: JournalMood {
        get { JournalMood(rawValue: moodRaw) ?? .okay }
        set { moodRaw = newValue.rawValue }
    }
}
