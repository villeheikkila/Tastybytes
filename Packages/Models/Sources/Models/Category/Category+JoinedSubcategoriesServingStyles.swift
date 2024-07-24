import Foundation
public import Tagged

public extension Category {
    struct JoinedSubcategoriesServingStyles: Identifiable, Codable, Hashable, Sendable, CategoryProtocol {
        public let id: Category.Id
        public let name: String
        public let icon: String?
        public let subcategories: [Subcategory.Saved]
        public let servingStyles: [ServingStyle.Saved]

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case icon
            case subcategories
            case servingStyles = "serving_styles"
        }

        init(
            id: Category.Id,
            name: String,
            icon: String? = nil,
            subcategories: [Subcategory.Saved],
            servingStyles: [ServingStyle.Saved]
        ) {
            self.id = id
            self.name = name
            self.icon = icon
            self.subcategories = subcategories
            self.servingStyles = servingStyles
        }

        public init(category: Category.Detailed) {
            id = category.id
            name = category.name
            icon = category.icon
            subcategories = category.subcategories
            servingStyles = category.servingStyles
        }

        public init() {
            id = .init(rawValue: 0)
            name = ""
            icon = nil
            subcategories = []
            servingStyles = []
        }

        public func copyWith(
            id: Category.Id? = nil,
            name: String? = nil,
            icon: String? = nil,
            subcategories: [Subcategory.Saved]? = nil,
            servingStyles: [ServingStyle.Saved]? = nil
        ) -> Self {
            .init(
                id: id ?? self.id,
                name: name ?? self.name,
                icon: icon ?? self.icon,
                subcategories: subcategories ?? self.subcategories,
                servingStyles: servingStyles ?? self.servingStyles
            )
        }

        public func appending(subcategory: Subcategory.Saved) -> JoinedSubcategoriesServingStyles {
            copyWith(subcategories: subcategories + [subcategory])
        }
    }
}
