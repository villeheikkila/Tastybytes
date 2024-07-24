import Foundation
public import Tagged

public extension ImageEntity {
    struct JoinedCheckIn: Codable, Hashable, Sendable, Identifiable, ImageEntityUrl {
        public let id: ImageEntity.Id
        public let file: String
        public let bucket: String
        public let blurHash: BlurHash?
        public let checkIn: CheckIn.Minimal

        public init(checkIn: CheckIn, imageEntity: ImageEntity.Saved) {
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
