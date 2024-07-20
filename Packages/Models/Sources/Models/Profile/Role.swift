import Tagged

public struct Role: Identifiable, Codable, Hashable, Sendable {
    public let id: Role.Id
    public let name: String
    public let permissions: [Permission]

    public var label: String {
        name.split(separator: "_")
            .map(\.capitalized)
            .joined(separator: " ")
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case permissions
    }
}

public extension Role {
    typealias Id = Tagged<Role, Int>
}

public enum RoleName: String {
    case admin
    case user
    case moderator
    case pro
    case superAdmin = "super_admin"
}
