public import Tagged

public extension Product.Variant {
    struct JoinedProduct: Identifiable, Codable, Hashable, Sendable {
        public let id: Product.Variant.Id
        public let product: Product.Joined

        enum CodingKeys: String, CodingKey {
            case id
            case product = "products"
        }
    }
}
