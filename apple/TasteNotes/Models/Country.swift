struct Country: Identifiable {
    var id: String { countryCode }
    let countryCode: String
    let name: String
    let emoji: String
}

extension Country: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(countryCode)
    }
    
    static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.countryCode == rhs.countryCode
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

extension Country: Decodable {
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
