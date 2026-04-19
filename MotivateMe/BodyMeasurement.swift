//
//  BodyMeasurement.swift
//  MotivateMe
//
//  User-logged weight and body measurements over time.
//  `type` is a String for extensibility (new measurement types shouldn't
//  require a migration); app layer validates against a known set.
//

import Foundation
import SwiftData

@Model
final class BodyMeasurement {
    var id: UUID = UUID()
    var date: Date = Date()
    var type: String = "weight"
    var value: Double = 0.0
    var unit: Unit = Unit.pounds

    init() {}
}
