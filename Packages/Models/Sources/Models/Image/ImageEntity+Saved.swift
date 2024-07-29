import Foundation
public import Tagged

public extension ImageEntity {
    struct Saved: Codable, Hashable, Sendable, Identifiable, ImageEntityProtocol {
        public let id: ImageEntity.Id
        public let file: String
        public let bucket: String
        public let blurHash: BlurHash?
        public let createdAt: Date

        public init(id: ImageEntity.Id, file: String, bucket: String, blurHash: BlurHash?, createdAt: Date) {
            self.id = id
            self.file = file
            self.bucket = bucket
            self.blurHash = blurHash
            self.createdAt = createdAt
        }

        enum CodingKeys: String, CodingKey {
            case id
            case file
            case bucket
            case blurHash = "blur_hash"
            case createdAt = "created_at"
        }
    }
}
