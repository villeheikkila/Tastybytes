import Foundation
import Logging

protocol StorageProtocol<Item> {
    associatedtype Item: Codable

    func save(_ item: Item) throws
    func load() throws -> Item?
    func clear() throws
}

struct DiskStorage<T: Codable>: StorageProtocol {
    typealias Item = T

    private let storageURL: URL
    private let logger: Logger

    init(fileManager: FileManager, filename: String, directory: FileManager.SearchPathDirectory = .applicationSupportDirectory) {
        let urls = fileManager.urls(for: directory, in: .userDomainMask)
        storageURL = urls[0].appendingPathComponent(filename)
        logger = Logger(label: "Storage \(filename)")
    }

    func save(_ item: T) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(item)
        try FileManager.default.createDirectory(
            at: storageURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: storageURL, options: .atomicWrite)
        logger.debug("Item saved successfully to: \(storageURL.path)")
    }

    func load() throws -> T? {
        guard FileManager.default.fileExists(atPath: storageURL.path) else {
            logger.debug("No saved item found at: \(storageURL.path)")
            return nil
        }
        let data = try Data(contentsOf: storageURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let item = try decoder.decode(T.self, from: data)
        logger.debug("Item loaded successfully from: \(storageURL.path)")
        return item
    }

    func clear() throws {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return }
        try FileManager.default.removeItem(at: storageURL)
        logger.debug("Item cleared successfully from: \(storageURL.path)")
    }
}
