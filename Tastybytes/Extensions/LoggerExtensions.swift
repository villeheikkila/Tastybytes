import Foundation
import OSLog

extension Logger {
    init(category: String) {
        self.init(
            subsystem: Bundle.main.bundleIdentifier ?? "app",
            category: category
        )
    }
}
