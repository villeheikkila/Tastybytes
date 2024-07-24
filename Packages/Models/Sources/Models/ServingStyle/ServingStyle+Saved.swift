public import Tagged

public extension ServingStyle {
    struct Saved: Identifiable, Hashable, Codable, Sendable {
        public let id: ServingStyle.Id
        public let name: String

        public var label: String {
            name.capitalized
        }

        public init(id: ServingStyle.Id, name: String) {
            self.id = id
            self.name = name
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
}
