public import Tagged

public extension Profile {
    struct SubcategoryStatistics: Identifiable, Codable, Sendable {
        public let id: Subcategory.Id
        public let name: String
        public let count: Int

        public var subcategory: Subcategory.Saved {
            Subcategory.Saved(id: id, name: name, isVerified: true)
        }
    }
}

public extension Profile.SubcategoryStatistics {
    struct SubcategoryStatisticsParams: Codable, Sendable {
        public init(userId: Profile.Id, categoryId: Category.Id) {
            self.userId = userId
            self.categoryId = categoryId
        }

        public let userId: Profile.Id
        public let categoryId: Category.Id

        enum CodingKeys: String, CodingKey {
            case userId = "p_user_id"
            case categoryId = "p_category_id"
        }
    }
}
