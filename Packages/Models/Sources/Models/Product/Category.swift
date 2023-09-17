public protocol CategoryProtocol {
    var id: Int { get }
    var name: String { get }
    var icon: String { get }
}

public extension CategoryProtocol {
    var label: String {
        "\(icon) \(name)"
    }
}

public struct Category: Identifiable, Codable, Hashable, Sendable, CategoryProtocol {
    public init(id: Int, name: String, icon: String) {
        self.id = id
        self.name = name
        self.icon = icon
    }

    public let id: Int
    public let name: String
    public let icon: String
}

public extension Category {
    struct JoinedSubcategoriesServingStyles: Identifiable, Codable, Hashable, Sendable, CategoryProtocol {
        public let id: Int
        public let name: String
        public let icon: String
        public let subcategories: [Subcategory]
        public let servingStyles: [ServingStyle]

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case icon
            case subcategories
            case servingStyles = "serving_styles"
        }

        public func copyWith(
            id: Int? = nil,
            name: String? = nil,
            icon: String? = nil,
            subcategories: [Subcategory]? = nil,
            servingStyles: [ServingStyle]? = nil
        ) -> JoinedSubcategoriesServingStyles {
            JoinedSubcategoriesServingStyles(
                id: id ?? self.id,
                name: name ?? self.name,
                icon: icon ?? self.icon,
                subcategories: subcategories ?? self.subcategories,
                servingStyles: servingStyles ?? self.servingStyles
            )
        }

        public func appending(subcategory: Subcategory) -> JoinedSubcategoriesServingStyles {
            return copyWith(subcategories: subcategories + [subcategory])
        }
    }

    struct NewRequest: Codable, Sendable {
        public init(name: String) {
            self.name = name
        }

        public let name: String
    }

    struct NewServingStyleRequest: Codable, Sendable {
        public init(categoryId: Int, servingStyleId: Int) {
            self.categoryId = categoryId
            self.servingStyleId = servingStyleId
        }

        public let categoryId: Int
        public let servingStyleId: Int

        enum CodingKeys: String, CodingKey {
            case categoryId = "category_id"
            case servingStyleId = "serving_style_id"
        }
    }
}
