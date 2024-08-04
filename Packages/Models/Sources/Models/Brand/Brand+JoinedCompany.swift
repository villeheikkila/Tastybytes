import Foundation
public import Tagged

public extension Brand {
    struct JoinedCompany: Identifiable, Hashable, Codable, Sendable, BrandProtocol {
        public let id: Brand.Id
        public let name: String
        public let isVerified: Bool
        public let brandOwner: Company.Saved
        public let logos: [ImageEntity.Saved]

        public init(id: Brand.Id, name: String, isVerified: Bool, brandOwner: Company.Saved, logos: [ImageEntity.Saved]) {
            self.id = id
            self.name = name
            self.isVerified = isVerified
            self.brandOwner = brandOwner
            self.logos = logos
        }

        public init(brand: Brand.JoinedSubBrandsCompany) {
            id = brand.id
            name = brand.name
            isVerified = brand.isVerified
            brandOwner = brand.brandOwner
            logos = brand.logos
        }

        public init(brand: Brand.Detailed) {
            id = brand.id
            name = brand.name
            isVerified = brand.isVerified
            brandOwner = brand.brandOwner
            logos = brand.logos
        }

        public init() {
            id = .init(rawValue: 0)
            name = ""
            isVerified = false
            brandOwner = .init()
            logos = []
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case brandOwner = "companies"
            case logos = "brand_logos"
        }

        public func copyWith(
            name: String? = nil,
            isVerified: Bool? = nil,
            brandOwner: Company.Saved? = nil,
            logos: [ImageEntity.Saved]? = nil
        ) -> Self {
            .init(
                id: id,
                name: name ?? self.name,
                isVerified: isVerified ?? self.isVerified,
                brandOwner: brandOwner ?? self.brandOwner,
                logos: logos ?? self.logos
            )
        }
    }
}
