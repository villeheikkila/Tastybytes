struct Flavor: Identifiable, Codable, Hashable, Sendable {
    let id: Int
    let name: String

    var label: String {
        name.capitalized
    }
}

extension Flavor {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.flavors.rawValue
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

    struct NewRequest: Codable {
        let name: String
    }
}
