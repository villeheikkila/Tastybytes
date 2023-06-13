struct ServingStyle: Identifiable, Hashable, Codable, Sendable {
  let id: Int
  let name: String

  var label: String {
    name.capitalized
  }

  enum CodingKeys: String, CodingKey {
    case id
    case name
  }
}

extension ServingStyle {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "serving_styles"
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

extension ServingStyle {
  struct UpdateRequest: Codable {
    let id: Int
    let name: String
  }

  struct NewRequest: Codable {
    let name: String
  }
}