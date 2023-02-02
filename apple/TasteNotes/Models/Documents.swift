import Foundation

struct Document: Decodable {
  let document: String

  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "documents"
    let saved = "document"

    switch queryType {
    case .tableName:
      return tableName
    case let .saved(withTableName):
      return queryWithTableName(tableName, saved, withTableName)
    }
  }

  enum QueryType {
    case tableName
    case saved(_ withTableName: Bool)
  }

  enum Page: String, Encodable {
    case about
  }
}

extension Document {
  struct About: Decodable {
    let document: AboutPage
  }
}

struct AboutPage: Decodable {
  let summary: String
  let githubUrl: String
  let portfolioUrl: String
  let linkedInUrl: String

  enum CodingKeys: String, CodingKey {
    case summary
    case githubUrl = "github_url"
    case portfolioUrl = "portfolio_url"
    case linkedInUrl = "linked_in_url"
  }
}
