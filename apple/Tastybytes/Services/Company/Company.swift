import Foundation

protocol CompanyLogo {
  var logoFile: String? { get }
}

extension CompanyLogo {
  func getLogoUrl() -> URL? {
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
    let tableName = "companies"
    let saved = "id, name, logo_file, is_verified"
    let logoBucketId = "logos"
    let owner = queryWithTableName(tableName, saved, true)

    switch queryType {
    case .tableName:
      return tableName
    case .logoBucket:
      return logoBucketId
    case let .saved(withTableName):
      return queryWithTableName(tableName, saved, withTableName)
    case let .joinedBrandSubcategoriesOwner(withTableName):
      return queryWithTableName(tableName, joinWithComma(saved, owner, Brand.getQuery(.joined(true))), withTableName)
    }
  }

  enum QueryType {
    case tableName
    case logoBucket
    case saved(_ withTableName: Bool)
    case joinedBrandSubcategoriesOwner(_ withTableName: Bool)
  }
}

extension Company {
  struct NewRequest: Encodable {
    let name: String
  }

  struct UpdateRequest: Encodable {
    let id: Int
    let name: String
  }

  struct VerifyRequest: Encodable {
    let id: Int
    let isVerified: Bool

    enum CodingKeys: String, CodingKey {
      case id = "p_company_id"
      case isVerified = "p_is_verified"
    }
  }

  struct SummaryRequest: Encodable {
    let id: Int

    enum CodingKeys: String, CodingKey {
      case id = "p_company_id"
    }
  }

  struct Joined: Identifiable, Hashable, Decodable {
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
