import Foundation
public import Tagged

public extension Brand {
    struct JoinedSubBrandsCompany: Identifiable, Hashable, Codable, Sendable, BrandProtocol {
        public let id: Brand.Id
        public let name: String
        public let isVerified: Bool
        public let brandOwner: Company.Saved
        public let subBrands: [SubBrand.Saved]
        public let logos: [Logo.Saved]

        public init(brandOwner: Company.Saved, brand: JoinedSubBrandsProducts) {
            id = brand.id
            name = brand.name
            isVerified = brand.isVerified
            self.brandOwner = brandOwner
            subBrands = brand.subBrands
                .map {
                    .init(id: $0.id, name: $0.name, includesBrandName: $0.includesBrandName, isVerified: $0.isVerified)
                }
            logos = brand.logos
        }

        public init(subBrand: SubBrand.JoinedBrand) {
            id = subBrand.brand.id
            name = subBrand.brand.name
            isVerified = subBrand.brand.isVerified
            brandOwner = subBrand.brand.brandOwner
            subBrands = []
            logos = subBrand.brand.logos
        }

        public init(brand: Brand.JoinedCompany) {
            id = brand.id
            name = brand.name
            isVerified = brand.isVerified
            brandOwner = brand.brandOwner
            subBrands = []
            logos = brand.logos
        }

        public init(brand: Brand.Detailed) {
            id = brand.id
            name = brand.name
            isVerified = brand.isVerified
            brandOwner = brand.brandOwner
            subBrands = brand.subBrands.map {
                .init(id: $0.id, name: $0.name, includesBrandName: $0.includesBrandName, isVerified: $0.isVerified)
            }
            logos = brand.logos
        }

        public init(
            id: Brand.Id,
            name: String,
            isVerified: Bool,
            brandOwner: Company.Saved,
            subBrands: [SubBrand.Saved],
            logos: [Logo.Saved] = []
        ) {
            self.id = id
            self.name = name
            self.isVerified = isVerified
            self.brandOwner = brandOwner
            self.subBrands = subBrands
            self.logos = logos
        }

        public init() {
            id = .init(0)
            name = ""
            isVerified = false
            brandOwner = .init()
            subBrands = []
            logos = []
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case brandOwner = "companies"
            case subBrands = "sub_brands"
            case logos
        }

        public func copyWith(name: String? = nil,
                             isVerified: Bool? = nil,
                             brandOwner: Company.Saved? = nil,
                             subBrands: [SubBrand.Saved]? = nil,
                             logos: [Logo.Saved]? = nil) -> Self
        {
            .init(
                id: id,
                name: name ?? self.name,
                isVerified: isVerified ?? self.isVerified,
                brandOwner: brandOwner ?? self.brandOwner,
                subBrands: subBrands ?? self.subBrands,
                logos: logos ?? self.logos
            )
        }
    }
}
