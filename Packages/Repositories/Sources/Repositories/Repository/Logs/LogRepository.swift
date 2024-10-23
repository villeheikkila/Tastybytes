public protocol LogRepository: Sendable {
    func insertLogs(entries: [LogEntry]) async throws
}
