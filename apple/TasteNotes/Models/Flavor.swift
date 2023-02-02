struct Flavor: Identifiable, Decodable, Hashable {
  let id: Int
  let name: String

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: Flavor, rhs: Flavor) -> Bool {
    lhs.id == rhs.id
  }
}

extension Flavor {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "flavors"
    let saved = "id, name"

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
}
