import Foundation

public struct ImageEntity: Codable, Hashable, Sendable, Identifiable {
    public let id: Int
    public let file: String
    public let bucket: String

    public func getLogoUrl(baseUrl: URL) -> URL? {
        baseUrl.appendingPathComponent("storage/v1/object/public/\(bucket)/\(file)")
    }
}
