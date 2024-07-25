public struct Document: Codable, Sendable {
    public let document: String

    public enum Page: String, Codable {
        case about
    }
}
