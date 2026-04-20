//
//  JournalPrompts.swift
//  MotivateMe
//
//  Daily rotating prompts shown on the Journal landing card. Stable
//  per-day so the prompt doesn't shuffle while the user looks at it.
//

import Foundation

enum JournalPrompts {
    static let all: [String] = [
        "What's one small thing you're proud of from yesterday?",
        "What's one small thing you're grateful for today?",
        "What did you do for yourself today?",
        "What made today feel good?",
        "How did today treat you?",
        "What are you carrying that you can put down?",
        "What did you learn this week?",
        "What's one thing you want to remember?",
    ]

    static func today() -> String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return all[day % all.count]
    }
}
