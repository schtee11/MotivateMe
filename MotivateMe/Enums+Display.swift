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
}
