import Foundation
public import Tagged

public extension Brand {
    struct Saved: Identifiable, Hashable, Codable, Sendable, BrandProtocol {
        public let id: Brand.Id
        public let name: String
        public let isVerified: Bool
        public let logos: [ImageEntity.Saved]
        public let productCount: Int?

        public init() {
            id = .init(rawValue: 0)
            name = ""
            isVerified = false
            logos = []
            productCount = nil
        }

        public init(brand: BrandProtocol) {
            id = brand.id
            name = brand.name
            isVerified = brand.isVerified
            logos = brand.logos
            productCount = nil
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case logos = "brand_logos"
            case productCount = "product_count"
        }
    }
}
