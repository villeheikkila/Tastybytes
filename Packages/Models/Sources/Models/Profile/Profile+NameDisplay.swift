public extension Profile {
    enum NameDisplay: String, CaseIterable, Codable, Hashable, Sendable {
        case username
        case fullName = "full_name"
    }
}
