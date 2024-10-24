import Foundation
import Logging
import OSLog

public struct LogEntry: Codable, Sendable {
    let label: String
    let level: Logging.Logger.Level
    let message: String
    let metadata: Logging.Logger.Metadata?
    let source: String
    let file: String
    let function: String
    let line: UInt
    let timestamp: Date

    init(
        label: String,
        level: Logging.Logger.Level,
        message: Logging.Logger.Message,
        metadata: Logging.Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        self.label = label
        self.level = level
        self.message = message.description
        self.metadata = metadata
        self.source = source
        self.file = file
        self.function = function
        self.line = line
        timestamp = Date()
    }
}
