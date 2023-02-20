struct ServingStyle: Identifiable, Hashable, Decodable {
  enum Name: String, CaseIterable, Decodable, Identifiable, Equatable {
    var id: Self { self }
    case bottle
    case can
  }

  let id: Int
  let name: Name

  enum CodingKeys: String, CodingKey {
    case id
    case name
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: ServingStyle, rhs: ServingStyle) -> Bool {
    lhs.id == rhs.id
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
