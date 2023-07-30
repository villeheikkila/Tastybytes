struct Document: Codable, Sendable {
    let document: String

    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.documents.rawValue
        let saved = "document"

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

    enum Page: String, Codable {
        case about
    }
}

extension Document {
    struct About: Codable, Sendable {
        let document: AboutPage
    }
}

struct AboutPage: Codable {
    let summary: String
    let githubUrl: String
    let portfolioUrl: String
    let linkedInUrl: String

    enum CodingKeys: String, CodingKey {
        case summary
        case githubUrl = "github_url"
        case portfolioUrl = "portfolio_url"
        case linkedInUrl = "linked_in_url"
    }
}
