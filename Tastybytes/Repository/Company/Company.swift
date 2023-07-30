import Foundation

protocol CompanyLogo {
    var logoFile: String? { get }
}

extension CompanyLogo {
    var logoUrl: URL? {
        guard let logoFile else { return nil }
        return URL(bucketId: Company.getQuery(.logoBucket), fileName: logoFile)
    }
}

struct Company: Identifiable, Codable, Hashable, CompanyLogo {
    let id: Int
    let name: String
    let logoFile: String?
    let isVerified: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case logoFile = "logo_file"
        case isVerified = "is_verified"
    }
}

extension Company {
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

extension Company {
    struct NewRequest: Codable {
        let name: String
    }

    struct UpdateRequest: Codable {
        let id: Int
        let name: String
    }

    struct EditSuggestionRequest: Codable {
        let id: Int
        let name: String

        enum CodingKeys: String, CodingKey {
            case id = "company_id"
            case name
        }
    }

    struct VerifyRequest: Codable {
        let id: Int
        let isVerified: Bool

        enum CodingKeys: String, CodingKey {
            case id = "p_company_id"
            case isVerified = "p_is_verified"
        }
    }

    struct SummaryRequest: Codable {
        let id: Int

        enum CodingKeys: String, CodingKey {
            case id = "p_company_id"
        }
    }

    struct Joined: Identifiable, Hashable, Codable {
        let id: Int
        let name: String
        let logoUrl: String?
        let subsidiaries: [Company]
        let brands: [Brand.JoinedSubBrandsProducts]

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case subsidiaries = "companies"
            case brands
            case logoUrl
        }
    }
}
