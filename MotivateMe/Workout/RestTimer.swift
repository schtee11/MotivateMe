//
//  RestTimer.swift
//  MotivateMe
//
//  Observable countdown shared by every SetRow in an ActiveWorkoutView. One
//  instance per workout — mutates `remaining` every second from a Timer.
//  Starting a new countdown replaces any running one, so tapping multiple
//  checkmarks in a row just restarts the clock.
//

import Foundation
import SwiftUI

@Observable
@MainActor
final class RestTimer {
    private(set) var remaining: Int = 0
    private(set) var total: Int = 0
    private var timer: Timer?

    var isRunning: Bool { remaining > 0 }

    func start(seconds: Int) {
        guard seconds > 0 else {
            stop()
            return
        }
        timer?.invalidate()
        total = seconds
        remaining = seconds
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        remaining = 0
        total = 0
    }

    private func tick() {
        guard remaining > 0 else {
            stop()
            return
        }
        remaining -= 1
        if remaining == 0 {
            stop()
        }
    }
}
