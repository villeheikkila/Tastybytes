public protocol SubBrandProtocol {
    var id: Int { get }
    var name: String? { get }
    var isVerified: Bool { get }
}

public struct SubBrand: Identifiable, Hashable, Codable, Sendable, Comparable, SubBrandProtocol {
    public let id: Int
    public let name: String?
    public let isVerified: Bool

    public init(id: Int, name: String?, isVerified: Bool) {
        self.id = id
        self.name = name
        self.isVerified = isVerified
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
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
        public let isVerified: Bool
        public let brand: Brand.JoinedCompany

        public init(id: Int, name: String?, isVerified: Bool, brand: Brand.JoinedCompany) {
            self.id = id
            self.name = name
            self.brand = brand
            self.isVerified = isVerified
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case brand = "brands"
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
        public let isVerified: Bool
        public let products: [Product.JoinedCategory]

        public var subBrand: SubBrand {
            .init(id: id, name: name, isVerified: isVerified)
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case products
        }

        public static func < (lhs: JoinedProduct, rhs: JoinedProduct) -> Bool {
            switch (lhs.name, rhs.name) {
            case let (lhs?, rhs?): lhs < rhs
            case (nil, _): true
            case (_?, nil): false
            }
        }
    }
}

public extension SubBrand {
    struct NewRequest: Codable, Sendable {
        public let name: String
        public let brandId: Int

        enum CodingKeys: String, CodingKey, Sendable {
            case name
            case brandId = "brand_id"
        }

        public init(name: String, brandId: Int) {
            self.name = name
            self.brandId = brandId
        }
    }

    struct UpdateNameRequest: Codable, Sendable {
        public let id: Int
        public let name: String

        public init(id: Int, name: String) {
            self.id = id
            self.name = name
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
