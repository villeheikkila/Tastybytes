import Foundation
public import Tagged

public extension ImageEntity {
    struct Detailed: Decodable, Hashable, Sendable, Identifiable, ImageEntityUrl {
        public let id: ImageEntity.Id
        public let file: String
        public let bucket: String
        public let blurHash: BlurHash?
        public let checkIn: CheckIn.Joined
        public let reports: [Report.Joined]
        public let createdAt: Date
        public let createdBy: Profile.Saved

        init(id: ImageEntity.Id, file: String, bucket: String, blurHash: BlurHash? = nil, checkIn: CheckIn.Joined, reports: [Report.Joined], createdAt: Date, createdBy: Profile.Saved) {
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

        public func copyWith(reports: [Report.Joined]? = nil) -> Self {
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
