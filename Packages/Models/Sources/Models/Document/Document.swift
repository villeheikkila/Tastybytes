public struct Document: Codable, Sendable {
    public struct About: Codable, Sendable {
        public let document: AboutPage
    }

    public let document: String

    public enum Page: String, Codable {
        case about
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
