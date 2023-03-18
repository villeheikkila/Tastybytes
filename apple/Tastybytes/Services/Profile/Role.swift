struct Role: Identifiable, Decodable, Hashable, Sendable {
  let id: Int
  let name: String
  let permissions: [Permission]

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case permissions
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    id = try container.decode(Int.self, forKey: .id)
    name = try container.decode(String.self, forKey: .name)

    do {
      permissions = try container.decode([Permission].self, forKey: .permissions)
    } catch {
      permissions = []
    }
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
