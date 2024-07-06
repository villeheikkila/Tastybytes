import Foundation

public struct ImageEntity: Codable, Hashable, Sendable, Identifiable {
    public let id: Int
    public let file: String
    public let bucket: String
    public let blurHash: BlurHash?
    public let createdAt: Date

    public init(id: Int, file: String, bucket: String, blurHash: BlurHash?, createdAt: Date) {
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

    public func getLogoUrl(baseUrl: URL) -> URL? {
        baseUrl.appendingPathComponent("storage/v1/object/public/\(bucket)/\(file)")
    }
}

public extension ImageEntity {
    struct JoinedCheckIn: Codable, Hashable, Sendable, Identifiable {
        public let id: Int
        public let file: String
        public let bucket: String
        public let blurHash: BlurHash?
        public let checkIn: CheckIn.Minimal

        public init(checkIn: CheckIn, imageEntity: ImageEntity) {
            id = imageEntity.id
            file = imageEntity.file
            bucket = imageEntity.bucket
            blurHash = imageEntity.blurHash
            self.checkIn = .init(id: checkIn.id, createdBy: checkIn.profile.id)
        }

        enum CodingKeys: String, CodingKey {
            case id
            case file
            case bucket
            case blurHash = "blur_hash"
            case checkIn = "check_ins"
        }

        public func getLogoUrl(baseUrl: URL) -> URL? {
            baseUrl.appendingPathComponent("storage/v1/object/public/\(bucket)/\(file)")
        }
    }
}
