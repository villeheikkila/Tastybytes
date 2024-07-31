import Foundation
import OSLog
internal import Cache

extension Storage<String, Data>: @unchecked @retroactive Sendable {}

struct CacheClient: CacheProtocol {
    let logger = Logger(category: "SupabaseLogger")

    let storage: Storage<String, Data>

    func setData(key: String, data: Data) async {
        do {
            try await storage.async.setObject(data, forKey: key)
            // logger.info("Saved \(key) to storage")
        } catch {}
    }

    func getData(key: String) async -> Data? {
        do {
            // logger.info("Loading \(key) from storage")
            return try await storage.async.object(forKey: key)
        } catch {
            return nil
        }
    }

    init() {
        storage = try! Storage<String, Data>(
            diskConfig: .init(name: "Disk"),
            memoryConfig: .init(expiry: .seconds(86400)),
            transformer: TransformerFactory.forData()
        )
    }
}
