//
//  RestTimer.swift
//  MotivateMe
//
//  Observable countdown shared by every SetRow in an ActiveWorkoutView. One
//  instance per workout — mutates `remaining` every second from an async
//  Task loop. Starting a new countdown cancels any running one, so tapping
//  multiple checkmarks in a row just restarts the clock.
//
//  Uses Task + Task.sleep rather than Timer because Timer's scheduled-block
//  closure is @Sendable under Swift 6, which conflicts with capturing
//  @MainActor state.
//

import Foundation
import SwiftUI

@Observable
@MainActor
final class RestTimer {
    private(set) var remaining: Int = 0
    private(set) var total: Int = 0
    private var task: Task<Void, Never>?

    var isRunning: Bool { remaining > 0 }

    func start(seconds: Int) {
        guard seconds > 0 else {
            stop()
            return
        }
        task?.cancel()
        total = seconds
        remaining = seconds
        task = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { return }
                guard let self else { return }
                self.tick()
                if self.remaining == 0 { return }
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
        remaining = 0
        total = 0
    }

    private func tick() {
        guard remaining > 0 else { return }
        remaining -= 1
    }
}
