import Tagged

public extension Product {
    struct Variant: Identifiable, Codable, Hashable, Sendable {
        public let id: Product.Variant.Id
        public let manufacturer: Company

        enum CodingKeys: String, CodingKey {
            case id
            case manufacturer = "companies"
        }
    }
}

public extension Product.Variant {
    typealias Id = Tagged<Product.Variant, Int>
}
