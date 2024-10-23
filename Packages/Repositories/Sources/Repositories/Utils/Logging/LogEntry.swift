import Foundation
import Logging

public struct LogEntry: Codable, Sendable {
    let label: String
    let level: String
    let message: String
    let metadata: Logger.Metadata?
    let source: String
    let file: String
    let function: String
    let line: UInt
    let timestamp: Date

    init(
        label: String,
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        self.label = label
        self.level = level.rawValue
        self.message = message.description
        self.metadata = metadata
        self.source = source
        self.file = file
        self.function = function
        self.line = line
        timestamp = Date()
    }
}
