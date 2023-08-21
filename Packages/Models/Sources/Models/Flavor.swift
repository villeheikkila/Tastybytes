public struct Flavor: Identifiable, Codable, Hashable, Sendable {
    public let id: Int
    public let name: String

    public var label: String {
        name.capitalized
    }
}

public extension Flavor {
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
        public init(name: String) {
            self.name = name
        }

        let name: String
    }
}
