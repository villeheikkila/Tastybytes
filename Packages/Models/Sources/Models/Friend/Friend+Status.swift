public extension Friend {
    enum Status: String, Codable, Sendable {
        case pending, accepted, blocked
    }
}
