public struct ServingStyle: Identifiable, Hashable, Codable, Sendable {
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

    public let id: Int
    public let name: String

    public var label: String {
        name.capitalized
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
    }

    public func copyWith(name: String? = nil) -> Self {
        .init(
            id: id,
            name: name ?? self.name
        )
    }
}

public extension ServingStyle {
    struct UpdateRequest: Codable, Sendable {
        public init(id: Int, name: String) {
            self.id = id
            self.name = name
        }

        public let id: Int
        public let name: String
    }

    struct NewRequest: Codable, Sendable {
        public init(name: String) {
            self.name = name
        }

        public let name: String
    }
}
