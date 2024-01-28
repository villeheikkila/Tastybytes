import Foundation

public struct ImageEntity: Codable, Hashable, Sendable, Identifiable {
    public let id: Int
    public let file: String
    public let bucket: String
    public let blurHash: BlurHash?

    enum CodingKeys: String, CodingKey {
        case id
        case file
        case bucket
        case blurHash = "blur_hash"
    }

    public func getLogoUrl(baseUrl: URL) -> URL? {
        baseUrl.appendingPathComponent("storage/v1/object/public/\(bucket)/\(file)")
    }
}
