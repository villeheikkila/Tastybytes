public struct ServingStyle: Identifiable, Hashable, Codable, Sendable {
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

    public let id: Int
    public let name: String

    public var label: String {
        name.capitalized
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}

public extension ServingStyle {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.servingStyles.rawValue
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

public extension ServingStyle {
    struct UpdateRequest: Codable {
        public init(id: Int, name: String) {
            self.id = id
            self.name = name
        }

        public let id: Int
        public let name: String
    }

    struct NewRequest: Codable {
        public init(name: String) {
            self.name = name
        }

        public let name: String
    }
}
