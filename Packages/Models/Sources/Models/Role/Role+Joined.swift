public import Tagged

public extension Role {
    struct Joined: Identifiable, Codable, Hashable, Sendable {
        public let id: Role.Id
        public let name: String
        public let permissions: [Permission.Saved]

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
}
