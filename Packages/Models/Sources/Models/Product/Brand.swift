import Foundation
import Tagged

public protocol BrandProtocol: Verifiable {
    var id: Brand.Id { get }
    var name: String { get }
    var logos: [ImageEntity] { get }
    var isVerified: Bool { get }
}

public struct Brand: Identifiable, Hashable, Codable, Sendable, BrandProtocol {
    public let id: Brand.Id
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
    typealias Id = Tagged<Brand, Int>
}

public extension Brand {
    struct JoinedSubBrands: Identifiable, Hashable, Codable, Sendable, BrandProtocol {
        public init(id: Brand.Id, name: String, isVerified: Bool, subBrands: [SubBrand], logos: [ImageEntity]) {
            self.id = id
            self.name = name
            self.isVerified = isVerified
            self.subBrands = subBrands
            self.logos = logos
        }

        public let id: Brand.Id
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
        public init(id: Brand.Id, name: String, isVerified: Bool, brandOwner: Company, logos: [ImageEntity]) {
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

        public let id: Brand.Id
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
        public let id: Brand.Id
        public let name: String
        public let isVerified: Bool
        public let subBrands: [SubBrand.JoinedProduct]
        public let logos: [ImageEntity]

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
            case logos = "brand_logos"
        }
    }

    struct JoinedSubBrandsProductsCompany: Identifiable, Hashable, Codable, Sendable, BrandProtocol {
        public let id: Brand.Id
        public let name: String
        public let isVerified: Bool
        public let brandOwner: Company
        public let subBrands: [SubBrand.JoinedProduct]
        public let logos: [ImageEntity]

        public init(brandOwner: Company, brand: JoinedSubBrandsProducts) {
            id = brand.id
            name = brand.name
            isVerified = brand.isVerified
            self.brandOwner = brandOwner
            subBrands = brand.subBrands
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
            subBrands = brand.subBrands
            logos = brand.logos
        }

        public var productCount: Int {
            subBrands.flatMap(\.products).count
        }

        public init(id: Brand.Id, name: String, isVerified: Bool, brandOwner: Company, subBrands: [SubBrand.JoinedProduct], logos: [ImageEntity] = []) {
            self.id = id
            self.name = name
            self.isVerified = isVerified
            self.brandOwner = brandOwner
            self.subBrands = subBrands
            self.logos = logos
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case brandOwner = "companies"
            case subBrands = "sub_brands"
            case logos = "brand_logos"
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

    struct Detailed: Identifiable, Hashable, Codable, Sendable, BrandProtocol, ModificationInfo {
        public let id: Brand.Id
        public let name: String
        public let isVerified: Bool
        public let brandOwner: Company
        public let subBrands: [SubBrand.JoinedProduct]
        public let logos: [ImageEntity]
        public let editSuggestions: [EditSuggestion]
        public let createdBy: Profile?
        public let createdAt: Date
        public let updatedBy: Profile?
        public let updatedAt: Date?

        public var productCount: Int {
            subBrands.flatMap(\.products).count
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case brandOwner = "companies"
            case subBrands = "sub_brands"
            case logos = "brand_logos"
            case editSuggestions = "brand_edit_suggestions"
            case createdBy = "created_by"
            case createdAt = "created_at"
            case updatedBy = "updated_by"
            case updatedAt = "updated_at"
        }

        public func copyWith(
            name: String? = nil,
            isVerified: Bool? = nil,
            brandOwner: Company? = nil,
            subBrands: [SubBrand.JoinedProduct]? = nil,
            logos: [ImageEntity]? = nil,
            editSuggestions: [Brand.EditSuggestion]? = nil
        ) -> Self {
            .init(
                id: id,
                name: name ?? self.name,
                isVerified: isVerified ?? self.isVerified,
                brandOwner: brandOwner ?? self.brandOwner,
                subBrands: subBrands ?? self.subBrands,
                logos: logos ?? self.logos,
                editSuggestions: editSuggestions ?? self.editSuggestions,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedBy: updatedBy,
                updatedAt: updatedAt
            )
        }
    }
}

public extension Brand {
    struct NewRequest: Codable, Sendable {
        public let name: String
        public let brandOwnerId: Company.Id

        enum CodingKeys: String, CodingKey {
            case name, brandOwnerId = "brand_owner_id"
        }

        public init(name: String, brandOwnerId: Company.Id) {
            self.name = name
            self.brandOwnerId = brandOwnerId
        }
    }

    struct UpdateRequest: Codable, Sendable {
        public let id: Brand.Id
        public let name: String
        public let brandOwnerId: Company.Id?

        enum CodingKeys: String, CodingKey {
            case id, name, brandOwnerId = "brand_owner_id"
        }

        public init(id: Brand.Id, name: String, brandOwnerId: Company.Id?) {
            self.id = id
            self.name = name
            self.brandOwnerId = brandOwnerId
        }
    }

    struct EditSuggestion: Codable, Sendable, Identifiable, Hashable, Resolvable, CreationInfo {
        public typealias Id = Tagged<Brand.EditSuggestion, Int>

        public let id: Brand.EditSuggestion.Id
        public let brand: Brand
        public let name: String?
        public let brandOwner: Company?
        public let createdBy: Profile
        public let createdAt: Date
        public let resolvedAt: Date?

        enum CodingKeys: String, CodingKey {
            case id, brand = "brands", name, brandOwner = "companies", createdBy = "profiles", createdAt = "created_at", resolvedAt = "resolved_at"
        }

        public func copyWith(resolvedAt: Date?) -> Self {
            .init(id: id, brand: brand, name: name, brandOwner: brandOwner, createdBy: createdBy, createdAt: createdAt, resolvedAt: resolvedAt)
        }
    }

    struct EditSuggestionRequest: Encodable, Sendable {
        let brandId: Brand.Id
        let name: String?
        let brandOwnerId: Company.Id?

        public init(brand: Brand.JoinedSubBrandsProductsCompany, name: String?, brandOwner: Company?) {
            brandId = brand.id
            self.name = name
            brandOwnerId = brandOwner?.id
        }

        enum CodingKeys: String, CodingKey {
            case name, brandId = "brand_id", brandOwnerId = "brand_owner_id"
        }

        typealias Id = Tagged<Brand.EditSuggestion, Int>
    }

    struct VerifyRequest: Codable, Sendable {
        public let id: Brand.Id
        public let isVerified: Bool

        public init(id: Brand.Id, isVerified: Bool) {
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
