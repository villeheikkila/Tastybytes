import Tagged

public struct Flavor: Identifiable, Codable, Hashable, Sendable {
    public let id: Flavor.Id
    public let name: String

    public var label: String {
        name.capitalized
    }
}

public extension Flavor {
    typealias Id = Tagged<Flavor, Int>
}

public extension Flavor {
    struct NewRequest: Codable, Sendable {
        let name: String

        public init(name: String) {
            self.name = name
        }
    }
}
