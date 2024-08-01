import Foundation
public import Tagged

public extension Brand {
    struct Saved: Identifiable, Hashable, Codable, Sendable, BrandProtocol {
        public let id: Brand.Id
        public let name: String
        public let isVerified: Bool
        public let logos: [ImageEntity.Saved]

        public init() {
            id = .init(rawValue: 0)
            name = ""
            isVerified = false
            logos = []
        }

        public init(brand: BrandProtocol) {
            id = brand.id
            name = brand.name
            isVerified = brand.isVerified
            logos = brand.logos
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case logos = "brand_logos"
        }
    }
}
