import Foundation
public import Tagged

public extension ImageEntity {
    struct Saved: Codable, Hashable, Sendable, Identifiable, ImageEntityProtocol {
        public let id: ImageEntity.Id
        public let file: String
        public let bucket: String
        public let blurHash: String?
        public let width: Int?
        public let height: Int?
        public let createdAt: Date

        public init(id: ImageEntity.Id, file: String, bucket: String, blurHash: String?, width: Int?, height: Int?, createdAt: Date) {
            self.id = id
            self.file = file
            self.bucket = bucket
            self.blurHash = blurHash
            self.width = width
            self.height = height
            self.createdAt = createdAt
        }

        public init() {
            id = .init(rawValue: 0)
            file = ""
            bucket = ""
            blurHash = nil
            width = nil
            height = nil
            createdAt = Date()
        }

        enum CodingKeys: String, CodingKey {
            case id
            case file
            case bucket
            case blurHash = "blur_hash"
            case width
            case height
            case createdAt = "created_at"
        }
    }
}
