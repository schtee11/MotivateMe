//
//  ErrorPresenter.swift
//  MotivateMe
//
//  A tiny app-wide error surface. Code that fails (persistence, network,
//  library load) hands the Error here; a single alert attached to the root
//  view displays it. Callers no longer need to decide "swallow or crash" —
//  they report and continue.
//

import SwiftUI
import OSLog

@Observable
final class ErrorPresenter {
    var current: PresentedError?

    private static let log = Logger(subsystem: "com.williamtrout.MotivateMe", category: "error")

    /// Report an error to the user.
    /// - Parameters:
    ///   - error: the underlying error.
    ///   - context: one-line description of what the user was trying to do
    ///     ("Saving your check-in", "Deleting this session"). Shown above
    ///     the error's localized description.
    func present(_ error: Error, context: String? = nil) {
        Self.log.error("\(context ?? "error", privacy: .public): \(error.localizedDescription, privacy: .public)")
        current = PresentedError(underlying: error, context: context)
    }
}

struct PresentedError: Identifiable {
    let id = UUID()
    let underlying: Error
    let context: String?

    var title: String { "Something went wrong" }
    var message: String {
        if let context, !context.isEmpty {
            return "\(context).\n\n\(underlying.localizedDescription)"
        }
        return underlying.localizedDescription
    }
}

extension View {
    /// Attach at the root once. Any ErrorPresenter in the environment that
    /// reports an error will surface a single OK alert.
    func errorAlert(presenter: ErrorPresenter) -> some View {
        alert(
            presenter.current?.title ?? "",
            isPresented: Binding(
                get: { presenter.current != nil },
                set: { if !$0 { presenter.current = nil } }
            ),
            presenting: presenter.current
        ) { _ in
            Button("OK", role: .cancel) { }
        } message: { err in
            Text(err.message)
        }
    }
}
