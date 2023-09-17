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

public enum RoleName: String {
    case admin
    case user
    case moderator
    case pro
}
