public extension Profile {
    enum NameDisplay: String, CaseIterable, Codable, Equatable, Sendable {
        case username
        case fullName = "full_name"
    }
}
