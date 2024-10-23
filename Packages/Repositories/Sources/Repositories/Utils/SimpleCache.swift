import Foundation

actor SimpleCache<T: Codable> {
    private let cacheDirectoryUrl: URL
    private var cache: [T] = []

    init(filePath: String) throws {
        let cacheDirectoryUrl = try FileManager.default.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent(filePath)
        let data = try Data(contentsOf: cacheDirectoryUrl)
        let logs = try JSONDecoder().decode([T].self, from: data)
        cache = logs
        self.cacheDirectoryUrl = cacheDirectoryUrl
    }

    func insert(_ log: T) {
        cache.append(log)
    }

    func insert(_ logs: [T]) {
        cache.append(contentsOf: logs)
    }

    func get(count: Int) -> [T] {
        let sliceSize = min(count, cache.count)
        let poppedLogs = Array(cache[..<sliceSize])
        cache.removeFirst(sliceSize)
        return poppedLogs
    }

    func storeToDisk() throws {
        let data = try JSONSerialization.data(withJSONObject: cache)
        try data.write(to: cacheDirectoryUrl)
        cache = []
    }
}
