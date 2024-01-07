public struct Flavor: Identifiable, Codable, Hashable, Sendable {
    public let id: Int
    public let name: String

    public var label: String {
        name.capitalized
    }
}

public extension Flavor {
    struct NewRequest: Codable, Sendable {
        let name: String

        public init(name: String) {
            self.name = name
        }
    }
}
