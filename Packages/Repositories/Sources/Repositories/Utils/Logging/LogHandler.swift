import Foundation
import Logging

public struct CustomLogHandler: LogHandler {
    public typealias OnLogged = @Sendable (LogEntry) -> Void
    public var metadata: Logger.Metadata = [:]
    public var logLevel: Logger.Level = .debug

    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }

    private let label: String
    private let onLogged: OnLogged

    public init(label: String, onLogged: @escaping OnLogged) {
        self.label = label
        self.onLogged = onLogged
    }

    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        let combinedMetadata = self.metadata.merging(metadata ?? [:]) { $1 }
        let entry: LogEntry = .init(
            label: label,
            level: level,
            message: message,
            metadata: combinedMetadata,
            source: source,
            file: file,
            function: function,
            line: line
        )
        onLogged(entry)
    }
}
