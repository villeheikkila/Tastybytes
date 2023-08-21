public struct Country: Hashable, Codable, Sendable {
    public let countryCode: String
    public let name: String
    public let emoji: String

    enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case name
        case emoji
    }
}

public extension Country {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.countries.rawValue
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
