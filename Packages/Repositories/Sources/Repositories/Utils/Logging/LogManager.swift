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

public actor LogManager {
    public typealias OnLogsSent = @Sendable ([LogEntry]) async throws -> Void
    public typealias OnInternalLog = @Sendable (String) -> Void

    private let onLogsSent: OnLogsSent
    private let internalLog: OnInternalLog
    private let cache: SimpleCache<LogEntry>
    private let config: LogManagerConfig
    private var syncTask: Task<Void, Never>?

    public init(config: LogManagerConfig = .init(), onLogsSent: @escaping OnLogsSent, internalLog: @escaping OnInternalLog) throws {
        cache = try SimpleCache(filePath: "log-cache")
        self.onLogsSent = onLogsSent
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
        let logsToSync = await cache.get(count: count)
        guard !logsToSync.isEmpty else { return }
        do {
            try await onLogsSent(logsToSync)
            internalLog("Succesfully synced \(logsToSync.count) logs")
        } catch {
            internalLog("Failed to sync \(logsToSync.count) log events, \(error). Returning to cache")
            await cache.insert(logsToSync)
        }
    }

    public func log(_ entry: LogEntry) async {
        await cache.insert(entry)
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
            try await cache.storeToDisk()
        } catch {
            internalLog("Failed to store the logs to disk: \(error)")
        }
    }
}
