import Foundation
public import Tagged

public extension Product.Barcode {
    struct JoinedWithCreator: Identifiable, Hashable, Codable, Sendable, BarcodeProtocol {
        public let id: Product.Barcode.Id
        public let barcode: String
        public let type: String
        public let profile: Profile
        public let createdAt: Date

        enum CodingKeys: String, CodingKey {
            case id, barcode, type, profile = "profiles", createdAt = "created_at"
        }
    }
}
