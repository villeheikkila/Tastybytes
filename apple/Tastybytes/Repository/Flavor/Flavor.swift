struct Flavor: Identifiable, Decodable, Hashable, Sendable {
  let id: Int
  let name: String

  var label: String {
    name.capitalized
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

  struct NewRequest: Encodable {
    let name: String
  }
}
