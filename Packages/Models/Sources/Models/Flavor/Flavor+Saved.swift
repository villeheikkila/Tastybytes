public import Tagged

public extension Flavor {
    struct Saved: Identifiable, Codable, Hashable, Sendable {
        public let id: Flavor.Id
        public let name: String

        public var label: String {
            name.capitalized
        }
    }
}
