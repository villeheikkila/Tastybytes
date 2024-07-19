public extension Product {
    struct Variant: Identifiable, Codable, Hashable, Sendable {
        public let id: Int
        public let manufacturer: Company

        enum CodingKeys: String, CodingKey {
            case id
            case manufacturer = "companies"
        }
    }
}
