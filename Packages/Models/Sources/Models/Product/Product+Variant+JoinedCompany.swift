public import Tagged

public extension Product.Variant {
    struct JoinedCompany: Identifiable, Codable, Hashable, Sendable {
        public let id: Product.Variant.Id
        public let manufacturer: Company.Saved

        enum CodingKeys: String, CodingKey {
            case id
            case manufacturer = "companies"
        }
    }
}
