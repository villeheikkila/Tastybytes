public import Tagged

public extension Subcategory {
    struct Saved: Identifiable, Codable, Hashable, Sendable, SubcategoryProtocol, Comparable {
        public init(id: Subcategory.Id, name: String, isVerified: Bool) {
            self.id = id
            self.name = name
            self.isVerified = isVerified
        }

        public init(subcategory: Subcategory.JoinedCategory) {
            id = subcategory.id
            name = subcategory.name
            isVerified = subcategory.isVerified
        }

        public let id: Subcategory.Id
        public let name: String
        public let isVerified: Bool

        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.name < rhs.name
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
        }

        public func copyWith(name: String? = nil, isVerified: Bool? = nil) -> Self {
            .init(
                id: id,
                name: name ?? self.name,
                isVerified: isVerified ?? self.isVerified
            )
        }
    }
}
