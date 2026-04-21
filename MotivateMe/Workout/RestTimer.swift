//
//  RestTimer.swift
//  MotivateMe
//
//  Observable countdown shared by every SetRow in an ActiveWorkoutView. One
//  instance per workout — re-reads `remaining` from a stored wall-clock end
//  Date so backgrounding the app doesn't cause the display to drift or stall.
//  Starting a new countdown cancels any running one, so tapping multiple
//  checkmarks in a row just restarts the clock.
//

import Foundation
import SwiftUI

@Observable
@MainActor
final class RestTimer {
    private(set) var remaining: Int = 0
    private(set) var total: Int = 0
    private var endDate: Date?
    private var task: Task<Void, Never>?

    var isRunning: Bool { remaining > 0 }

    /// Total length of the current countdown — used by progress rings.
    var totalSeconds: Int { total }

    /// Add or subtract seconds from a running countdown. Floors at 1 (we
    /// don't want a +/- tap to silently end the timer; use stop() for that).
    func adjust(by seconds: Int) {
        guard isRunning else { return }
        let newRemaining = max(1, remaining + seconds)
        remaining = newRemaining
        total = max(total, newRemaining)
        // Shift the wall-clock end date too, otherwise the next tick of
        // recompute() would snap remaining back to the un-adjusted value.
        endDate = Date().addingTimeInterval(TimeInterval(newRemaining))
    }

    func start(seconds: Int) {
        guard seconds > 0 else {
            stop()
            return
        }
        task?.cancel()
        total = seconds
        let end = Date().addingTimeInterval(TimeInterval(seconds))
        endDate = end
        remaining = seconds
        task = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { return }
                guard let self else { return }
                self.recompute()
                if self.remaining == 0 { return }
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
        endDate = nil
        remaining = 0
        total = 0
    }

    /// Force an immediate read from the wall clock. Call when the app returns
    /// from background so the display snaps to the true remaining time rather
    /// than waiting up to a second for the next tick.
    func recompute() {
        guard let endDate else {
            remaining = 0
            return
        }
        let delta = endDate.timeIntervalSinceNow
        if delta <= 0 {
            remaining = 0
            self.endDate = nil
            task?.cancel()
            task = nil
        } else {
            remaining = Int(delta.rounded(.up))
        }
    }
}
