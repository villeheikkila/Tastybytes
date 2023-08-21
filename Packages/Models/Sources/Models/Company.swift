import Foundation

public protocol CompanyLogo {
    var logoFile: String? { get }
}

public extension CompanyLogo {
    var logoUrl: URL? {
        guard let logoFile else { return nil }
        return URL(bucketId: Company.getQuery(.logoBucket), fileName: logoFile)
    }
}

public struct Company: Identifiable, Codable, Hashable, Sendable, CompanyLogo {
    public init(id: Int, name: String, logoFile: String? = nil, isVerified: Bool) {
        self.id = id
        self.name = name
        self.logoFile = logoFile
        self.isVerified = isVerified
    }

    public let id: Int
    public let name: String
    public let logoFile: String?
    public let isVerified: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case logoFile = "logo_file"
        case isVerified = "is_verified"
    }
}

public extension Company {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.companies.rawValue
        let editSuggestionTable = "company_edit_suggestions"
        let saved = "id, name, logo_file, is_verified"
        let logoBucketId = "logos"
        let owner = queryWithTableName(tableName, saved, true)

        switch queryType {
        case .tableName:
            return tableName
        case .editSuggestionTable:
            return editSuggestionTable
        case .logoBucket:
            return logoBucketId
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        case let .joinedBrandSubcategoriesOwner(withTableName):
            return queryWithTableName(
                tableName,
                [saved, owner, Brand.getQuery(.joined(true))].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case editSuggestionTable
        case logoBucket
        case saved(_ withTableName: Bool)
        case joinedBrandSubcategoriesOwner(_ withTableName: Bool)
    }
}

public extension Company {
    struct NewRequest: Codable {
        public init(name: String) {
            self.name = name
        }

        public let name: String
    }

    struct UpdateRequest: Codable {
        public init(id: Int, name: String) {
            self.id = id
            self.name = name
        }

        public let id: Int
        public let name: String
    }

    struct EditSuggestionRequest: Codable {
        public init(id: Int, name: String) {
            self.id = id
            self.name = name
        }

        public let id: Int
        public let name: String

        enum CodingKeys: String, CodingKey {
            case id = "company_id"
            case name
        }
    }

    struct VerifyRequest: Codable {
        public init(id: Int, isVerified: Bool) {
            self.id = id
            self.isVerified = isVerified
        }

        public let id: Int
        public let isVerified: Bool

        enum CodingKeys: String, CodingKey {
            case id = "p_company_id"
            case isVerified = "p_is_verified"
        }
    }

    struct SummaryRequest: Codable {
        public init(id: Int) {
            self.id = id
        }

        public let id: Int

        enum CodingKeys: String, CodingKey {
            case id = "p_company_id"
        }
    }

    struct Joined: Identifiable, Hashable, Codable {
        public let id: Int
        public let name: String
        public let logoUrl: String?
        public let subsidiaries: [Company]
        public let brands: [Brand.JoinedSubBrandsProducts]

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case subsidiaries = "companies"
            case brands
            case logoUrl
        }
    }
}
