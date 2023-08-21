import Foundation

public protocol BrandProtocol {
    var id: Int { get }
    var name: String { get }
    var logoFile: String? { get }
    var isVerified: Bool { get }
}

public extension BrandProtocol {
    var logoUrl: URL? {
        guard let logoFile else { return nil }
        return URL(bucketId: Brand.getQuery(.logosBucket), fileName: logoFile)
    }
}

public enum Brand {
    public static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.brands.rawValue
        let saved = "id, name, is_verified, logo_file"
        let logosBucketId = "brand-logos"

        switch queryType {
        case .tableName:
            return tableName
        case .logosBucket:
            return logosBucketId
        case let .joinedSubBrands(withTableName):
            return queryWithTableName(tableName, [saved, SubBrand.getQuery(.saved(true))].joinComma(), withTableName)
        case let .joined(withTableName):
            return queryWithTableName(tableName, [saved, SubBrand.getQuery(.joined(true))].joinComma(), withTableName)
        case let .joinedCompany(withTableName):
            return queryWithTableName(tableName, [saved, Company.getQuery(.saved(true))].joinComma(), withTableName)
        case let .joinedSubBrandsCompany(withTableName):
            return queryWithTableName(
                tableName,
                [saved, SubBrand.getQuery(.joined(true)), Company.getQuery(.saved(true))].joinComma(),
                withTableName
            )
        }
    }

    public enum QueryType {
        case tableName
        case logosBucket
        case joined(_ withTableName: Bool)
        case joinedSubBrands(_ withTableName: Bool)
        case joinedCompany(_ withTableName: Bool)
        case joinedSubBrandsCompany(_ withTableName: Bool)
    }
}

public extension Brand {
    struct JoinedSubBrands: Identifiable, Hashable, Codable, Sendable, BrandProtocol {
        public init(id: Int, name: String, logoFile: String? = nil, isVerified: Bool, subBrands: [SubBrand]) {
            self.id = id
            self.name = name
            self.logoFile = logoFile
            self.isVerified = isVerified
            self.subBrands = subBrands
        }

        public let id: Int
        public let name: String
        public let logoFile: String?
        public let isVerified: Bool
        public let subBrands: [SubBrand]

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case logoFile = "logo_file"
            case isVerified = "is_verified"
            case subBrands = "sub_brands"
        }
    }

    struct JoinedCompany: Identifiable, Hashable, Codable, Sendable, BrandProtocol {
        public init(id: Int, name: String, logoFile: String? = nil, isVerified: Bool, brandOwner: Company) {
            self.id = id
            self.name = name
            self.logoFile = logoFile
            self.isVerified = isVerified
            self.brandOwner = brandOwner
        }

        public let id: Int
        public let name: String
        public let logoFile: String?
        public let isVerified: Bool
        public let brandOwner: Company

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case logoFile = "logo_file"
            case isVerified = "is_verified"
            case brandOwner = "companies"
        }
    }

    struct JoinedSubBrandsProducts: Identifiable, Hashable, Codable, Sendable, BrandProtocol {
        public let id: Int
        public let name: String
        public let logoFile: String?
        public let isVerified: Bool
        public let subBrands: [SubBrand.JoinedProduct]

        public func getNumberOfProducts() -> Int {
            subBrands.flatMap(\.products).count
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case logoFile = "logo_file"
            case isVerified = "is_verified"
            case subBrands = "sub_brands"
        }
    }

    struct JoinedSubBrandsProductsCompany: Identifiable, Hashable, Codable, Sendable, BrandProtocol {
        public let id: Int
        public let name: String
        public let logoFile: String?
        public let isVerified: Bool
        public let brandOwner: Company
        public let subBrands: [SubBrand.JoinedProduct]

        public init(brandOwner: Company, brand: JoinedSubBrandsProducts) {
            id = brand.id
            name = brand.name
            isVerified = brand.isVerified
            self.brandOwner = brandOwner
            logoFile = brand.logoFile
            subBrands = brand.subBrands
        }

        public func getNumberOfProducts() -> Int {
            subBrands.flatMap(\.products).count
        }

        public init(id: Int, name: String, isVerified: Bool, brandOwner: Company, subBrands: [SubBrand.JoinedProduct]) {
            self.id = id
            self.name = name
            self.isVerified = isVerified
            self.brandOwner = brandOwner
            self.subBrands = subBrands
            logoFile = nil
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case logoFile = "logo_file"
            case isVerified = "is_verified"
            case brandOwner = "companies"
            case subBrands = "sub_brands"
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
