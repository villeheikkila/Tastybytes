import Foundation
import Logging

public struct LogManagerConfig: Sendable {
    let syncInterval: TimeInterval
    let syncCount: Int

    public init(syncInterval: TimeInterval = 32, syncCount: Int = 64) {
        self.syncInterval = syncInterval
        self.syncCount = syncCount
    }
}

public protocol LogManagerProtocol: Sendable {
    func log(_ entry: LogEntry)
}

public actor CachedLogManager: LogManagerProtocol {
    public typealias OnLogsSent = @Sendable ([LogEntry]) async throws -> Void
    public typealias OnInternalLog = @Sendable (String) -> Void

    private let onSyncLogs: OnLogsSent
    private let internalLog: OnInternalLog
    private let cache: any SimpleCacheProtocol<LogEntry>
    private let config: LogManagerConfig
    private var syncTask: Task<Void, Never>?

    public init(cache: any SimpleCacheProtocol<LogEntry>, config: LogManagerConfig = .init(), onLogsSent: @escaping OnLogsSent, internalLog: @escaping OnInternalLog) throws {
        self.cache = cache
        onSyncLogs = onLogsSent
        self.internalLog = internalLog
        self.config = config
    }

    private func startSyncing() {
        let syncInterval = config.syncInterval
        let syncCount = config.syncCount
        syncTask?.cancel()
        syncTask = Task {
            while !Task.isCancelled {
                await sync(count: syncCount)
                try? await Task.sleep(for: .seconds(syncInterval))
            }
        }
    }

    private func sync(count: Int) async {
        let logsToSync = try? await cache.get(count: count)
        guard let logsToSync, !logsToSync.isEmpty else { return }
        do {
            try await onSyncLogs(logsToSync)
            internalLog("Succesfully synced \(logsToSync.count) logs")
        } catch {
            internalLog("Failed to sync \(logsToSync.count) log events, \(error). Returning to cache")
            _ = try? await cache.append(logsToSync)
        }
    }

    public nonisolated func log(_ entry: LogEntry) {
        Task {
            try await cache.append(entry)
        }
    }

    public func pauseSyncing() {
        syncTask?.cancel()
        syncTask = nil
    }

    public func resumeSyncing() {
        startSyncing()
    }

    public func storeToDisk() async throws {
        do {
            try await cache.persist()
        } catch {
            internalLog("Failed to store the logs to disk: \(error)")
        }
    }
}
