import Foundation

public protocol SubBrandProtocol {
    var id: Int { get }
    var name: String? { get }
    var includesBrandName: Bool { get }
    var isVerified: Bool { get }
}

public struct SubBrand: Identifiable, Hashable, Codable, Sendable, Comparable, SubBrandProtocol {
    public let id: Int
    public let name: String?
    public let includesBrandName: Bool
    public let isVerified: Bool

    public init(id: Int, name: String?, includesBrandName: Bool, isVerified: Bool) {
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
    struct JoinedBrand: Identifiable, Hashable, Codable, Sendable, Comparable, SubBrandProtocol {
        public let id: Int
        public let name: String?
        public let includesBrandName: Bool
        public let isVerified: Bool
        public let brand: Brand.JoinedCompany

        public init(id: Int, name: String?, includesBrandName: Bool, isVerified: Bool, brand: Brand.JoinedCompany) {
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
        public let id: Int
        public let name: String?
        public let includesBrandName: Bool
        public let isVerified: Bool
        public let products: [Product.JoinedCategory]
        public let createdAt: Date?
        public let createdBy: Profile?

        public var subBrand: SubBrand {
            .init(id: id, name: name, includesBrandName: includesBrandName, isVerified: isVerified)
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case includesBrandName = "includes_brand_name"
            case products
            case createdAt = "created_at"
            case createdBy = "profiles"
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
                products: products ?? self.products,
                createdAt: createdAt,
                createdBy: createdBy
            )
        }
    }
}

public extension SubBrand {
    struct NewRequest: Codable, Sendable {
        let name: String
        let brandId: Int
        let includesBrandName: Bool

        enum CodingKeys: String, CodingKey, Sendable {
            case name
            case brandId = "brand_id"
            case includesBrandName = "includes_brand_name"
        }

        public init(name: String, brandId: Int, includesBrandName: Bool) {
            self.name = name
            self.brandId = brandId
            self.includesBrandName = includesBrandName
        }
    }

    struct UpdateNameRequest: Codable, Sendable {
        public let id: Int
        public let name: String
        public let includesBrandName: Bool

        public init(id: Int, name: String, includesBrandName: Bool) {
            self.id = id
            self.name = name
            self.includesBrandName = includesBrandName
        }

        enum CodingKeys: String, CodingKey {
            case id, name, includesBrandName = "includes_brand_name"
        }
    }

    struct UpdateBrandRequest: Codable, Sendable {
        public let id: Int
        public let brandId: Int

        enum CodingKeys: String, CodingKey {
            case id, brandId = "brand_id"
        }

        public init(id: Int, brandId: Int) {
            self.id = id
            self.brandId = brandId
        }
    }

    struct VerifyRequest: Codable, Sendable {
        public init(id: Int, isVerified: Bool) {
            self.id = id
            self.isVerified = isVerified
        }

        public let id: Int
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
