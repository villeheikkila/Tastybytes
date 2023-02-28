struct Country: Identifiable, Hashable, Decodable {
  var id: String { countryCode }
  let countryCode: String
  let name: String
  let emoji: String

  init(countryCode: String, name: String, emoji: String) {
    self.countryCode = countryCode
    self.name = name
    self.emoji = emoji
  }

  enum CodingKeys: String, CodingKey {
    case id
    case countryCode = "country_code"
    case name
    case emoji
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    countryCode = try container.decode(String.self, forKey: .countryCode)
    name = try container.decode(String.self, forKey: .name)
    emoji = try container.decode(String.self, forKey: .emoji)
  }
}

extension Country {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "countries"
    let saved = "country_code, name, emoji"

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
