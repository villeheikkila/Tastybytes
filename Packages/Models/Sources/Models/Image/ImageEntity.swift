import Foundation
import Tagged

public protocol ImageEntityUrl {
    var file: String { get }
    var bucket: String { get }
    var blurHash: BlurHash? { get }
}

public extension ImageEntity {
    enum EntityError: Error {
        case failedToFormUrl
    }
}

public extension ImageEntityUrl {
    func getLogoUrl(baseUrl: URL) -> URL? {
        baseUrl.appendingPathComponent("storage/v1/object/public/\(bucket)/\(file)")
    }
}

public struct ImageEntity: Codable, Hashable, Sendable, Identifiable, ImageEntityUrl {
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

public extension ImageEntity {
    typealias Id = Tagged<ImageEntity, Int>
}

public extension ImageEntity {
    struct JoinedCheckIn: Codable, Hashable, Sendable, Identifiable, ImageEntityUrl {
        public let id: ImageEntity.Id
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
    }
}

public extension ImageEntity {
    struct Detailed: Decodable, Hashable, Sendable, Identifiable, ImageEntityUrl {
        public let id: ImageEntity.Id
        public let file: String
        public let bucket: String
        public let blurHash: BlurHash?
        public let checkIn: CheckIn
        public let reports: [Report]
        public let createdAt: Date
        public let createdBy: Profile

        init(id: ImageEntity.Id, file: String, bucket: String, blurHash: BlurHash? = nil, checkIn: CheckIn, reports: [Report], createdAt: Date, createdBy: Profile) {
            self.id = id
            self.file = file
            self.bucket = bucket
            self.blurHash = blurHash
            self.checkIn = checkIn
            self.reports = reports
            self.createdAt = createdAt
            self.createdBy = createdBy
        }

        public init() {
            id = .init(rawValue: 0)
            file = ""
            bucket = ""
            blurHash = nil
            checkIn = .init()
            reports = []
            createdAt = Date.now
            createdBy = .init()
        }

        enum CodingKeys: String, CodingKey {
            case id
            case file
            case bucket
            case blurHash = "blur_hash"
            case checkIn = "check_ins"
            case reports
            case createdAt = "created_at"
            case createdBy = "profiles"
        }

        public func copyWith(reports: [Report]? = nil) -> Self {
            .init(
                id: id,
                file: file,
                bucket: bucket,
                blurHash: blurHash,
                checkIn: checkIn,
                reports: reports ?? self.reports,
                createdAt: createdAt,
                createdBy: createdBy
            )
        }
    }
}
