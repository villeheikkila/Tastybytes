import Foundation
import OSLog

public extension Logger {
    init(category: String) {
        self.init(
            subsystem: Bundle.main.bundleIdentifier ?? "app",
            category: category
        )
    }
}
