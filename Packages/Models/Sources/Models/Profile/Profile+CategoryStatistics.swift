public import Tagged

public extension Profile {
    struct CategoryStatistics: Identifiable, Codable, Sendable, CategoryProtocol {
        public let id: Category.Id
        public let name: String
        public let icon: String?
        public let count: Int

        public var category: Category.Saved {
            Category.Saved(id: id, name: name, icon: icon)
        }
    }
}
