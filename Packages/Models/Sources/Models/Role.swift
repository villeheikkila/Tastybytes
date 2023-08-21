public struct Role: Identifiable, Codable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let permissions: [Permission]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case permissions
    }
}

public extension Role {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.roles.rawValue
        let saved = "id, name"

        switch queryType {
        case .tableName:
            return tableName
        case let .joined(withTableName):
            return queryWithTableName(tableName, [saved, Permission.getQuery(.saved(true))].joinComma(), withTableName)
        }
    }

    enum QueryType {
        case tableName
        case joined(_ withTableName: Bool)
    }
}

public enum RoleName: String {
    case admin
    case user
    case moderator
    case pro
}
