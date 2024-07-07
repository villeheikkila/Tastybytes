import Foundation

public protocol BrandProtocol {
    var id: Int { get }
    var name: String { get }
    var logos: [ImageEntity] { get }
    var isVerified: Bool { get }
}

public struct Brand: Identifiable, Hashable, Codable, Sendable, BrandProtocol {
    public let id: Int
    public let name: String
    public let isVerified: Bool
    public let logos: [ImageEntity]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case isVerified = "is_verified"
        case logos = "brand_logos"
    }
}

public extension Brand {
    struct JoinedSubBrands: Identifiable, Hashable, Codable, Sendable, BrandProtocol {
        public init(id: Int, name: String, isVerified: Bool, subBrands: [SubBrand], logos: [ImageEntity]) {
            self.id = id
            self.name = name
            self.isVerified = isVerified
            self.subBrands = subBrands
            self.logos = logos
        }

        public let id: Int
        public let name: String
        public let isVerified: Bool
        public let subBrands: [SubBrand]
        public let logos: [ImageEntity]

        public init(brand: Brand.JoinedSubBrandsProductsCompany) {
            self.init(
                id: brand.id,
                name: brand.name,
                isVerified: brand.isVerified,
                subBrands: brand.subBrands.map(\.subBrand),
                logos: brand.logos
            )
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case subBrands = "sub_brands"
            case logos = "brand_logos"
        }
    }

    struct JoinedCompany: Identifiable, Hashable, Codable, Sendable, BrandProtocol {
        public init(id: Int, name: String, isVerified: Bool, brandOwner: Company, logos: [ImageEntity]) {
            self.id = id
            self.name = name
            self.isVerified = isVerified
            self.brandOwner = brandOwner
            self.logos = logos
        }

        init(brand: Brand.JoinedSubBrandsProductsCompany) {
            id = brand.id
            name = brand.name
            isVerified = brand.isVerified
            brandOwner = brand.brandOwner
            logos = brand.logos
        }

        public let id: Int
        public let name: String
        public let isVerified: Bool
        public let brandOwner: Company
        public let logos: [ImageEntity]

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case brandOwner = "companies"
            case logos = "brand_logos"
        }
    }

    struct JoinedSubBrandsProducts: Identifiable, Hashable, Codable, Sendable, BrandProtocol {
        public let id: Int
        public let name: String
        public let isVerified: Bool
        public let subBrands: [SubBrand.JoinedProduct]
        public let logos: [ImageEntity]

        public var productCount: Int {
            subBrands.flatMap(\.products).count
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case subBrands = "sub_brands"
            case logos = "brand_logos"
        }
    }

    struct JoinedSubBrandsProductsCompany: Identifiable, Hashable, Codable, Sendable, BrandProtocol {
        public let id: Int
        public let name: String
        public let isVerified: Bool
        public let brandOwner: Company
        public let subBrands: [SubBrand.JoinedProduct]
        public let logos: [ImageEntity]
        public let createdBy: Profile?
        public let createdAt: Date?

        public init(brandOwner: Company, brand: JoinedSubBrandsProducts) {
            id = brand.id
            name = brand.name
            isVerified = brand.isVerified
            self.brandOwner = brandOwner
            subBrands = brand.subBrands
            logos = brand.logos
            createdBy = nil
            createdAt = nil
        }

        public init(subBrand: SubBrand.JoinedBrand) {
            id = subBrand.brand.id
            name = subBrand.brand.name
            isVerified = subBrand.brand.isVerified
            brandOwner = subBrand.brand.brandOwner
            subBrands = []
            logos = subBrand.brand.logos
            createdBy = nil
            createdAt = nil
        }

        public init(brand: Brand.JoinedCompany) {
            id = brand.id
            name = brand.name
            isVerified = brand.isVerified
            brandOwner = brand.brandOwner
            subBrands = []
            logos = brand.logos
            createdBy = nil
            createdAt = nil
        }

        public var productCount: Int {
            subBrands.flatMap(\.products).count
        }

        public init(id: Int, name: String, isVerified: Bool, brandOwner: Company, subBrands: [SubBrand.JoinedProduct], logos: [ImageEntity] = []) {
            self.id = id
            self.name = name
            self.isVerified = isVerified
            self.brandOwner = brandOwner
            self.subBrands = subBrands
            self.logos = logos
            createdBy = nil
            createdAt = nil
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case brandOwner = "companies"
            case subBrands = "sub_brands"
            case logos = "brand_logos"
            case createdBy = "profiles"
            case createdAt = "created_at"
        }

        public func copyWith(name: String? = nil,
                             isVerified: Bool? = nil,
                             brandOwner: Company? = nil,
                             subBrands: [SubBrand.JoinedProduct]? = nil,
                             logos: [ImageEntity]? = nil) -> Self
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

public extension Brand {
    struct NewRequest: Codable, Sendable {
        public let name: String
        public let brandOwnerId: Int

        enum CodingKeys: String, CodingKey {
            case name, brandOwnerId = "brand_owner_id"
        }

        public init(name: String, brandOwnerId: Int) {
            self.name = name
            self.brandOwnerId = brandOwnerId
        }
    }

    struct UpdateRequest: Codable, Sendable {
        public let id: Int
        public let name: String
        public let brandOwnerId: Int

        enum CodingKeys: String, CodingKey {
            case id, name, brandOwnerId = "brand_owner_id"
        }

        public init(id: Int, name: String, brandOwnerId: Int) {
            self.id = id
            self.name = name
            self.brandOwnerId = brandOwnerId
        }
    }

    struct VerifyRequest: Codable, Sendable {
        public let id: Int
        public let isVerified: Bool

        public init(id: Int, isVerified: Bool) {
            self.id = id
            self.isVerified = isVerified
        }

        enum CodingKeys: String, CodingKey {
            case id = "p_brand_id"
            case isVerified = "p_is_verified"
        }
    }
}

public extension BrandProtocol {
    func getLogoUrl(baseUrl: URL) -> URL? {
        guard let logo = logos.first else { return nil }
        return logo.getLogoUrl(baseUrl: baseUrl)
    }
}
