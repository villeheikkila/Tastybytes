public import Tagged

public extension Subcategory {
    struct NewRequest: Codable, Sendable {
        public let name: String
        public let categoryId: Category.Id

        enum CodingKeys: String, CodingKey {
            case name, categoryId = "category_id"
        }

        public init(name: String, category: Models.Category.JoinedSubcategoriesServingStyles) {
            self.name = name
            categoryId = category.id
        }
    }

    struct VerifyRequest: Codable, Sendable {
        public init(id: Subcategory.Id, isVerified: Bool) {
            self.id = id
            self.isVerified = isVerified
        }

        public let id: Subcategory.Id
        public let isVerified: Bool

        enum CodingKeys: String, CodingKey {
            case id = "p_subcategory_id"
            case isVerified = "p_is_verified"
        }
    }

    struct UpdateRequest: Codable, Sendable {
        public let id: Subcategory.Id
        public let name: String

        enum CodingKeys: String, CodingKey {
            case id, name
        }

        public init(id: Subcategory.Id, name: String) {
            self.id = id
            self.name = name
        }
    }
}
