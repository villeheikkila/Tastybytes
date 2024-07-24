public import Tagged

public extension Product {
    struct JoinedCategory: Identifiable, Codable, Hashable, Sendable {
        public let id: Product.Id
        public let name: String?
        public let description: String?
        public let isVerified: Bool
        public let isDiscontinued: Bool
        public let category: Category.Saved
        public let subcategories: [Subcategory.JoinedCategory]
        public let logos: [ImageEntity.Saved]

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case description
            case isVerified = "is_verified"
            case isDiscontinued = "is_discontinued"
            case category = "categories"
            case subcategories
            case logos = "product_logos"
        }

        public init(product: Product.Joined) {
            id = product.id
            name = product.name
            description = product.description
            isVerified = product.isVerified
            category = product.category
            subcategories = product.subcategories
            isDiscontinued = product.isDiscontinued
            logos = product.logos
        }

        public init(
            id: Product.Id,
            name: String?,
            description: String?,
            isVerified: Bool,
            isDiscontinued: Bool,
            category: Category.Saved,
            subcategories: [Subcategory.JoinedCategory],
            logos: [ImageEntity.Saved]
        ) {
            self.id = id
            self.name = name
            self.description = description
            self.isVerified = isVerified
            self.category = category
            self.subcategories = subcategories
            self.isDiscontinued = isDiscontinued
            self.logos = logos
        }
    }
}
