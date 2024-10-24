import Foundation
import OSLog

public struct OSLogManager: LogManagerProtocol {
    private let subsystem: String

    public init(subsystem: String) {
        self.subsystem = subsystem
    }

    public func log(_ entry: LogEntry) {
        let logger = Logger(subsystem: subsystem, category: entry.label)
        let osLogType: OSLogType = switch entry.level {
        case .trace, .debug:
            .debug
        case .info:
            .info
        case .notice, .warning:
            .default
        case .error:
            .error
        case .critical:
            .fault
        }

        let metadataString = if let metadata = entry.metadata, !metadata.isEmpty {
            " metadata: \(String(describing: entry.metadata))"
        } else {
            ""
        }
        let fileURL = URL(fileURLWithPath: entry.file)
        let fileName = fileURL.lastPathComponent
        let message = """
        [\(fileName):\(entry.line) \(entry.function)] 
        \(entry.message)\(metadataString)
        """
        logger.log(level: osLogType, "\(message, privacy: .public)")
    }
}
