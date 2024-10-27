import Foundation

@globalActor public actor CacheActor {
    public static let shared = CacheActor()
    private init() {}
}

public enum CacheError: Error {
    case invalidData
    case encodingFailed
    case decodingFailed
    case fileOperationFailed
}

public protocol SimpleCacheProtocol<T>: Sendable {
    associatedtype T: Codable & Sendable
    @discardableResult
    func append(_ item: T) async throws -> Bool
    @discardableResult
    func append(_ items: [T]) async throws -> Bool
    func get(count: Int) async throws -> [T]
    func clear() async throws
    func persist() async throws
}

@CacheActor
public final class SimpleCache<T: Codable & Sendable>: SimpleCacheProtocol {
    private let cacheDirectoryUrl: URL
    private var cache: [T] = []
    private let maxCacheSize: Int
    private let fileManager: FileManager
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    public init(
        fileName: String,
        maxCacheSize: Int = 1000,
        fileManager: FileManager = .default
    ) throws {
        self.maxCacheSize = maxCacheSize
        self.fileManager = fileManager
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
        let fileNameWithExtension = fileName.hasSuffix(".json") ? fileName : "\(fileName).json"
        self.cacheDirectoryUrl = try fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appendingPathComponent(fileNameWithExtension)
        
        try loadFromDisk()
    }
    
    public var count: Int {
        cache.count
    }
    
    @discardableResult
    public func append(_ item: T) async throws -> Bool {
        guard cache.count < maxCacheSize else {
            throw CacheError.invalidData
        }
        cache.append(item)
        try await persist()
        return true
    }
    
    @discardableResult
    public func append(_ items: [T]) async throws -> Bool {
        guard cache.count + items.count <= maxCacheSize else {
            throw CacheError.invalidData
        }
        cache.append(contentsOf: items)
        try await persist()
        return true
    }
    
    public func get(count: Int) async throws -> [T] {
        let sliceSize = min(count, cache.count)
        let items = Array(cache[..<sliceSize])
        cache.removeFirst(sliceSize)
        try await persist()
        return items
    }
    
    public func clear() async throws {
        cache.removeAll()
        try await persist()
    }
    
    private func loadFromDisk() throws {
        if fileManager.fileExists(atPath: cacheDirectoryUrl.path) {
            let data = try Data(contentsOf: cacheDirectoryUrl)
            cache = try decoder.decode([T].self, from: data)
        } else {
            cache = []
            try "[]".data(using: .utf8)?.write(to: cacheDirectoryUrl)
        }
    }
    
    public func persist() async throws {
        do {
            let data = try encoder.encode(cache)
            try data.write(to: cacheDirectoryUrl, options: .atomicWrite)
        } catch {
            throw CacheError.fileOperationFailed
        }
    }
}

public enum CacheFactory {
    @CacheActor public static func makeCache<T: Codable>(
        for type: T.Type,
        fileName: String,
        maxSize: Int = 1000
    ) throws -> SimpleCache<T> {
        try SimpleCache<T>(fileName: fileName, maxCacheSize: maxSize)
    }
}
