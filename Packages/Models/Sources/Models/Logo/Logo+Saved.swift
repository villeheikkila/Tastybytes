import Foundation
public import Tagged

public extension Logo {
    struct Saved: Codable, Hashable, Sendable, Identifiable, ImageEntityProtocol {
        public let id: Logo.Id
        public let file: String
        public let bucket: String
        public let blurHash: String?
        public let width: Int?
        public let height: Int?
        public let createdAt: Date
        public let label: String

        public init(id: Logo.Id, file: String, bucket: String, label: String, blurHash: String, width: Int, height: Int, createdAt: Date) {
            self.id = id
            self.file = file
            self.bucket = bucket
            self.label = label
            self.blurHash = blurHash
            self.width = width
            self.height = height
            self.createdAt = createdAt
        }

        enum CodingKeys: String, CodingKey {
            case id
            case file
            case label
            case bucket
            case blurHash = "blur_hash"
            case width
            case height
            case createdAt = "created_at"
        }
    }
}
