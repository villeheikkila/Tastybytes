import Foundation
public import Tagged

public extension ImageEntity {
    struct CheckInId: Codable, Hashable, Sendable, Identifiable, ImageEntityProtocol {
        public let id: ImageEntity.Id
        public let file: String
        public let bucket: String
        public let blurHash: BlurHash?
        public let checkInId: CheckIn.Id

        public init(checkIn: CheckIn.Joined, imageEntity: ImageEntity.Saved) {
            id = imageEntity.id
            file = imageEntity.file
            bucket = imageEntity.bucket
            blurHash = imageEntity.blurHash
            self.checkInId =  checkIn.id
        }

        enum CodingKeys: String, CodingKey {
            case id
            case file
            case bucket
            case blurHash = "blur_hash"
            case checkInId = "check_in_id"
        }
    }
}
