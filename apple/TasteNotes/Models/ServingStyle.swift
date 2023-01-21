struct ServingStyle: Identifiable {
  let id: Int
  let name: ServingStyleName
}

enum ServingStyleName: String, CaseIterable, Decodable, Identifiable, Equatable {
  var id: Self { self }
  case bottle
  case can
  case none
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

extension ServingStyle: Decodable {
  enum CodingKeys: String, CodingKey {
    case id
    case name
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(Int.self, forKey: .id)
    name = try values.decode(ServingStyleName.self, forKey: .name)
  }
}

extension ServingStyle: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: ServingStyle, rhs: ServingStyle) -> Bool {
    lhs.id == rhs.id
  }
}
