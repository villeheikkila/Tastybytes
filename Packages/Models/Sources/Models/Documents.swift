public struct Document: Codable, Sendable {
    public let document: String

    public static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.documents.rawValue
        let saved = "document"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        }
    }

    public enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
    }

    public enum Page: String, Codable {
        case about
    }
}

public extension Document {
    struct About: Codable, Sendable {
        public let document: AboutPage
    }
}

public struct AboutPage: Codable, Sendable {
    public let summary: String
    public let githubUrl: String
    public let portfolioUrl: String
    public let linkedInUrl: String

    enum CodingKeys: String, CodingKey {
        case summary
        case githubUrl = "github_url"
        case portfolioUrl = "portfolio_url"
        case linkedInUrl = "linked_in_url"
    }
}
