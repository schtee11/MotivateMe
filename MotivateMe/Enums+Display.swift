//
//  Enums+Display.swift
//  MotivateMe
//
//  Human-readable labels for the domain enums. Kept out of Enums.swift so the
//  raw model stays focused on storage/serialization — these are presentation
//  strings and would move to a .strings catalog once we localize.
//

import Foundation

extension Goal {
    var displayName: String {
        switch self {
        case .buildHabit:    return "Build a habit"
        case .loseWeight:    return "Lose weight"
        case .getStronger:   return "Get stronger"
        case .generalHealth: return "General health"
        }
    }
}

extension ExperienceLevel {
    var displayName: String {
        switch self {
        case .firstTime: return "First time"
        case .returning: return "Coming back"
        case .casual:    return "Casual"
        case .serious:   return "Serious"
        }
    }

    var descriptionText: String {
        switch self {
        case .firstTime: return "Brand new to structured training."
        case .returning: return "Trained before, getting back into it."
        case .casual:    return "Work out regularly, no strict program."
        case .serious:   return "Follow a program, track progress."
        }
    }

    // Ordinal used to compare levels — e.g. to filter templates whose
    // minimumExperienceLevel a given user qualifies for.
    var rank: Int {
        switch self {
        case .firstTime: return 0
        case .returning: return 1
        case .casual:    return 2
        case .serious:   return 3
        }
    }
}

extension Equipment {
    var displayName: String {
        switch self {
        case .dumbbells:       return "Dumbbells"
        case .barbell:         return "Barbell"
        case .bench:           return "Bench"
        case .pullUpBar:       return "Pull-up bar"
        case .resistanceBands: return "Resistance bands"
        case .kettlebells:     return "Kettlebells"
        case .cableMachine:    return "Cable machine"
        case .none:            return "None"
        }
    }
}

extension SplitStyle {
    var displayName: String {
        switch self {
        case .fullBody:     return "Full body"
        case .upperLower:   return "Upper / Lower"
        case .pushPullLegs: return "Push / Pull / Legs"
        }
    }

    var descriptionText: String {
        switch self {
        case .fullBody:     return "One workout hits everything. Good for 2–4 days/week."
        case .upperLower:   return "Alternate upper and lower. Good for 4 days/week."
        case .pushPullLegs: return "Split by movement. Good for 5–6 days/week."
        }
    }
}

extension Unit {
    var displayName: String {
        switch self {
        case .pounds:      return "Pounds (lb)"
        case .kilograms:   return "Kilograms (kg)"
        case .inches:      return "Inches (in)"
        case .centimeters: return "Centimeters (cm)"
        }
    }
}

extension Weekday {
    var displayName: String {
        switch self {
        case .monday:    return "Monday"
        case .tuesday:   return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday:  return "Thursday"
        case .friday:    return "Friday"
        case .saturday:  return "Saturday"
        case .sunday:    return "Sunday"
        }
    }

    var shortName: String {
        switch self {
        case .monday:    return "Mon"
        case .tuesday:   return "Tue"
        case .wednesday: return "Wed"
        case .thursday:  return "Thu"
        case .friday:    return "Fri"
        case .saturday:  return "Sat"
        case .sunday:    return "Sun"
        }
    }

    // Map Foundation's Calendar weekday component (1 = Sunday) into our
    // Monday-first domain enum. Extracted so the Today screen and any
    // future scheduler logic share a single conversion point.
    static func from(date: Date, calendar: Calendar = .current) -> Weekday {
        switch calendar.component(.weekday, from: date) {
        case 1:  return .sunday
        case 2:  return .monday
        case 3:  return .tuesday
        case 4:  return .wednesday
        case 5:  return .thursday
        case 6:  return .friday
        case 7:  return .saturday
        default: return .monday
        }
    }
}

extension TemplateCategory {
    var displayName: String {
        switch self {
        case .fullBody: return "Full body"
        case .upper:    return "Upper body"
        case .lower:    return "Lower body"
        case .push:     return "Push"
        case .pull:     return "Pull"
        case .legs:     return "Legs"
        case .mobility: return "Mobility"
        }
    }

    // Stable ordering for the picker's section headers.
    var sortOrder: Int {
        switch self {
        case .fullBody: return 0
        case .upper:    return 1
        case .lower:    return 2
        case .push:     return 3
        case .pull:     return 4
        case .legs:     return 5
        case .mobility: return 6
        }
    }
}

extension EffortLevel {
    var displayName: String {
        switch self {
        case .easy:     return "Easy"
        case .moderate: return "Moderate"
        case .hard:     return "Hard"
        }
    }

    // Stored on Session.effortRating as a plain Int for CloudKit simplicity.
    var rating: Int {
        switch self {
        case .easy:     return 1
        case .moderate: return 2
        case .hard:     return 3
        }
    }

    nonisolated init?(rating: Int) {
        switch rating {
        case 1: self = .easy
        case 2: self = .moderate
        case 3: self = .hard
        default: return nil
        }
    }
}
