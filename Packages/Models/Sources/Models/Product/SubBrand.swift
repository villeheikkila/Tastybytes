import Foundation
import Tagged

public protocol SubBrandProtocol: Verifiable {
    var id: SubBrand.Id { get }
    var name: String? { get }
    var includesBrandName: Bool { get }
    var isVerified: Bool { get }
}

public struct SubBrand: Identifiable, Hashable, Codable, Sendable, Comparable, SubBrandProtocol {
    public let id: SubBrand.Id
    public let name: String?
    public let includesBrandName: Bool
    public let isVerified: Bool

    public init(id: SubBrand.Id, name: String?, includesBrandName: Bool, isVerified: Bool) {
        self.id = id
        self.name = name
        self.includesBrandName = includesBrandName
        self.isVerified = isVerified
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case includesBrandName = "includes_brand_name"
        case isVerified = "is_verified"
    }

    public static func < (lhs: SubBrand, rhs: SubBrand) -> Bool {
        switch (lhs.name, rhs.name) {
        case let (lhs?, rhs?): lhs < rhs
        case (nil, _): true
        case (_?, nil): false
        }
    }
}

public extension SubBrand {
    typealias Id = Tagged<SubBrand, Int>
}

public extension SubBrand {
    struct JoinedBrand: Identifiable, Hashable, Codable, Sendable, Comparable, SubBrandProtocol {
        public let id: SubBrand.Id
        public let name: String?
        public let includesBrandName: Bool
        public let isVerified: Bool
        public let brand: Brand.JoinedCompany

        public init(id: SubBrand.Id, name: String?, includesBrandName: Bool, isVerified: Bool, brand: Brand.JoinedCompany) {
            self.id = id
            self.name = name
            self.includesBrandName = includesBrandName
            self.brand = brand
            self.isVerified = isVerified
        }

        public init(brand: Brand.JoinedSubBrandsProductsCompany, subBrand: SubBrand.JoinedProduct) {
            id = subBrand.id
            name = subBrand.name
            isVerified = subBrand.isVerified
            includesBrandName = subBrand.includesBrandName
            self.brand = .init(brand: brand)
        }

        public init(subBrand: SubBrand.Detailed) {
            id = subBrand.id
            name = subBrand.name
            isVerified = subBrand.isVerified
            includesBrandName = subBrand.includesBrandName
            brand = .init(brand: subBrand.brand)
        }

        public init() {
            id = .init(rawValue: 0)
            name = ""
            includesBrandName = false
            brand = .init()
            isVerified = false
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case brand = "brands"
            case includesBrandName = "includes_brand_name"
            case isVerified = "is_verified"
        }

        public static func < (lhs: JoinedBrand, rhs: JoinedBrand) -> Bool {
            switch (lhs.name, rhs.name) {
            case let (lhs?, rhs?): lhs < rhs
            case (nil, _): true
            case (_?, nil): false
            }
        }
    }

    struct JoinedProduct: Identifiable, Hashable, Codable, Sendable, Comparable, SubBrandProtocol {
        public let id: SubBrand.Id
        public let name: String?
        public let includesBrandName: Bool
        public let isVerified: Bool
        public let products: [Product.JoinedCategory]

        public init(id: SubBrand.Id, name: String? = nil, includesBrandName: Bool, isVerified: Bool, products: [Product.JoinedCategory]) {
            self.id = id
            self.name = name
            self.includesBrandName = includesBrandName
            self.isVerified = isVerified
            self.products = products
        }

        public init(subBrand: SubBrand.Detailed) {
            id = subBrand.id
            name = subBrand.name
            includesBrandName = subBrand.includesBrandName
            isVerified = subBrand.isVerified
            products = subBrand.products
        }

        public var subBrand: SubBrand {
            .init(id: id, name: name, includesBrandName: includesBrandName, isVerified: isVerified)
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case includesBrandName = "includes_brand_name"
            case products
        }

        public static func < (lhs: JoinedProduct, rhs: JoinedProduct) -> Bool {
            switch (lhs.name, rhs.name) {
            case let (lhs?, rhs?): lhs < rhs
            case (nil, _): true
            case (_?, nil): false
            }
        }

        public func copyWith(name: String? = nil, includesBrandName: Bool? = nil, isVerified: Bool? = nil, products: [Product.JoinedCategory]? = nil) -> Self {
            .init(
                id: id,
                name: name ?? self.name,
                includesBrandName: includesBrandName ?? self.includesBrandName,
                isVerified: isVerified ?? self.isVerified,
                products: products ?? self.products
            )
        }
    }

    struct Detailed: Identifiable, Hashable, Decodable, Sendable, SubBrandProtocol, ModificationInfo {
        public let id: SubBrand.Id
        public let name: String?
        public let includesBrandName: Bool
        public let isVerified: Bool
        public let products: [Product.JoinedCategory]
        public let brand: Brand.JoinedCompany
        public let editSuggestions: [SubBrand.EditSuggestion]
        public let reports: [Report]
        public let createdAt: Date
        public let createdBy: Profile?
        public let updatedAt: Date?
        public let updatedBy: Profile?

        init(
            id: SubBrand.Id,
            name: String? = nil,
            includesBrandName: Bool,
            isVerified: Bool,
            products: [Product.JoinedCategory],
            brand: Brand.JoinedCompany,
            editSuggestions: [SubBrand.EditSuggestion],
            reports: [Report],
            createdAt: Date,
            createdBy: Profile? = nil,
            updatedAt: Date? = nil,
            updatedBy: Profile? = nil
        ) {
            self.id = id
            self.name = name
            self.includesBrandName = includesBrandName
            self.isVerified = isVerified
            self.products = products
            self.brand = brand
            self.editSuggestions = editSuggestions
            self.reports = reports
            self.createdAt = createdAt
            self.createdBy = createdBy
            self.updatedAt = updatedAt
            self.updatedBy = updatedBy
        }

        public init() {
            id = SubBrand.Id(rawValue: 0)
            name = ""
            includesBrandName = false
            isVerified = false
            products = []
            brand = .init()
            editSuggestions = []
            reports = []
            createdAt = Date.now
            createdBy = nil
            updatedAt = nil
            updatedBy = nil
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case includesBrandName = "includes_brand_name"
            case products
            case brand = "brands"
            case editSuggestions = "sub_brand_edit_suggestions"
            case reports
            case createdBy = "created_by"
            case createdAt = "created_at"
            case updatedBy = "updated_by"
            case updatedAt = "updated_at"
        }

        public func copyWith(name: String? = nil, includesBrandName: Bool? = nil, isVerified: Bool? = nil, products: [Product.JoinedCategory]? = nil, brand: Brand.JoinedCompany? = nil, editSuggestions: [SubBrand.EditSuggestion]? = nil, reports: [Report]? = nil) -> Self {
            .init(
                id: id,
                name: name ?? self.name,
                includesBrandName: includesBrandName ?? self.includesBrandName,
                isVerified: isVerified ?? self.isVerified,
                products: products ?? self.products,
                brand: brand ?? self.brand,
                editSuggestions: editSuggestions ?? self.editSuggestions,
                reports: reports ?? self.reports,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy
            )
        }
    }

    struct EditSuggestion: Identifiable, Codable, Hashable, Sendable, Resolvable, CreationInfo {
        public typealias Id = Tagged<SubBrand.EditSuggestion, Int>

        public let id: SubBrand.EditSuggestion.Id
        public let subBrand: SubBrand.JoinedBrand
        public let createdAt: Date
        public let createdBy: Profile
        public let brand: Brand?
        public let name: String?
        public let includesBrandName: Bool?
        public let resolvedAt: Date?

        enum CodingKeys: String, CodingKey, Sendable {
            case id
            case name
            case createdAt = "created_at"
            case createdBy = "profiles"
            case brand = "brands"
            case subBrand = "sub_brands"
            case includesBrandName = "includes_brand_name"
            case resolvedAt = "resolved_at"
        }
    }
}

public extension SubBrand {
    struct NewRequest: Codable, Sendable {
        let name: String
        let brandId: Brand.Id
        let includesBrandName: Bool

        enum CodingKeys: String, CodingKey, Sendable {
            case name
            case brandId = "brand_id"
            case includesBrandName = "includes_brand_name"
        }

        public init(name: String, brandId: Brand.Id, includesBrandName: Bool) {
            self.name = name
            self.brandId = brandId
            self.includesBrandName = includesBrandName
        }
    }

    struct UpdateNameRequest: Codable, Sendable {
        public let id: SubBrand.Id
        public let name: String
        public let includesBrandName: Bool

        public init(id: SubBrand.Id, name: String, includesBrandName: Bool) {
            self.id = id
            self.name = name
            self.includesBrandName = includesBrandName
        }

        enum CodingKeys: String, CodingKey {
            case id, name, includesBrandName = "includes_brand_name"
        }
    }

    struct UpdateBrandRequest: Codable, Sendable {
        public let id: SubBrand.Id
        public let brandId: Brand.Id

        enum CodingKeys: String, CodingKey {
            case id, brandId = "brand_id"
        }

        public init(id: SubBrand.Id, brandId: Brand.Id) {
            self.id = id
            self.brandId = brandId
        }
    }

    struct VerifyRequest: Codable, Sendable {
        public init(id: SubBrand.Id, isVerified: Bool) {
            self.id = id
            self.isVerified = isVerified
        }

        public let id: SubBrand.Id
        public let isVerified: Bool

        enum CodingKeys: String, CodingKey {
            case id = "p_sub_brand_id"
            case isVerified = "p_is_verified"
        }
    }

    enum Update: Sendable {
        case brand(UpdateBrandRequest)
        case name(UpdateNameRequest)
    }
}
