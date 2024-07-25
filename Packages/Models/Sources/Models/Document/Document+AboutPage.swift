public extension Document {
    struct About: Codable, Sendable {
        public let document: Document.About.Page
    }
}

public extension Document.About {
    struct Page: Codable, Sendable {
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
}
