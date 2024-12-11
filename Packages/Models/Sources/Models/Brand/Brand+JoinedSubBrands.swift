import Foundation
public import Tagged

public extension Brand {
    struct JoinedSubBrands: Identifiable, Hashable, Codable, Sendable, BrandProtocol {
        public let id: Brand.Id
        public let name: String
        public let isVerified: Bool
        public let subBrands: [SubBrand.Saved]
        public let logos: [Logo.Saved]

        public init(id: Brand.Id, name: String, isVerified: Bool, subBrands: [SubBrand.Saved], logos: [Logo.Saved]) {
            self.id = id
            self.name = name
            self.isVerified = isVerified
            self.subBrands = subBrands
            self.logos = logos
        }

        public init(brand: Brand.JoinedSubBrandsCompany) {
            self.init(
                id: brand.id,
                name: brand.name,
                isVerified: brand.isVerified,
                subBrands: brand.subBrands,
                logos: brand.logos
            )
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
