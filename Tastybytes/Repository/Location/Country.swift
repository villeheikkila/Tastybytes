struct Country: Hashable, Codable, Sendable {
    let countryCode: String
    let name: String
    let emoji: String

    enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case name
        case emoji
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
