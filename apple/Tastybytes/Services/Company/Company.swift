import Foundation

struct Company: Identifiable, Codable, Hashable {
  let id: Int
  let name: String
  let logoUrl: String?
  let isVerified: Bool

  func getLogoUrl() -> URL? {
    if let logoUrl {
      let bucketId = "logos"
      let urlString = "\(Config.supabaseUrl.absoluteString)/storage/v1/object/public/\(bucketId)/\(logoUrl)"
      return URL(string: urlString)
    } else {
      return nil
    }
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(logoUrl)
  }

  static func == (lhs: Company, rhs: Company) -> Bool {
    lhs.id == rhs.id
  }

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case logoUrl = "logo_url"
    case isVerified = "is_verified"
  }
}

extension Company {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "companies"
    let saved = "id, name, logo_url, is_verified"
    let owner = queryWithTableName(tableName, saved, true)

    switch queryType {
    case .tableName:
      return tableName
    case let .saved(withTableName):
      return queryWithTableName(tableName, saved, withTableName)
    case let .joinedBrandSubcategoriesOwner(withTableName):
      return queryWithTableName(tableName, joinWithComma(saved, owner, Brand.getQuery(.joined(true))), withTableName)
    }
  }

  enum QueryType {
    case tableName
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

    enum CodingKeys: String, CodingKey {
      case id = "p_company_id"
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

    static func == (lhs: Joined, rhs: Joined) -> Bool {
      lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
      case id
      case name
      case subsidiaries = "companies"
      case brands
      case logoUrl
    }
  }
}