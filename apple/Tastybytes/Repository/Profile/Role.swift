struct Role: Identifiable, Decodable, Hashable, Sendable {
  let id: Int
  let name: String
  let permissions: [Permission]

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case permissions
  }
}

extension Role {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "roles"
    let saved = "id, name"

    switch queryType {
    case .tableName:
      return tableName
    case let .joined(withTableName):
      return queryWithTableName(tableName, [saved, Permission.getQuery(.saved(true))].joinComma(), withTableName)
    }
  }

  enum QueryType {
    case tableName
    case joined(_ withTableName: Bool)
  }
}

enum RoleName: String {
  case admin
  case user
  case moderator
  case premium
}
