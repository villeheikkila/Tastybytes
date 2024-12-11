import Foundation
public import Tagged

public extension Brand {
    struct JoinedSubBrandsProducts: Identifiable, Hashable, Codable, Sendable, BrandProtocol {
        public let id: Brand.Id
        public let name: String
        public let isVerified: Bool
        public let subBrands: [SubBrand.JoinedProduct]
        public let logos: [Logo.Saved]

        public init(newBrand: JoinedSubBrands) {
            id = newBrand.id
            name = newBrand.name
            isVerified = newBrand.isVerified
            subBrands = []
            logos = newBrand.logos
        }

        public var productCount: Int {
            subBrands.flatMap(\.products).count
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case subBrands = "sub_brands"
            case logos
        }
    }
}
