import Foundation
import os

protocol Loggable {
    static var logCategory: String { get }
    static var logger: Logger { get }
}

extension Loggable {
    static var logger: Logger {
        Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: Self.logCategory
        )
    }
}

