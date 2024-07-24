public import Tagged

public extension Permission {
    struct Saved: Identifiable, Codable, Hashable, Sendable {
        public let id: Permission.Id
        public let name: String

        public var label: String {
            name.split(separator: "_")
                .map(\.capitalized)
                .joined(separator: " ")
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
        }
    }
}
