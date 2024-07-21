import Foundation
import Tagged

public protocol CategoryProtocol: Sendable {
    var id: Category.Id { get }
    var name: String { get }
    var icon: String? { get }
}

public extension CategoryProtocol {
    var label: String {
        if let icon {
            "\(icon) \(name)"
        } else {
            name
        }
    }
}

public struct Category: Identifiable, Codable, Hashable, Sendable, CategoryProtocol {
    public let id: Category.Id
    public let name: String
    public let icon: String?

    public init(id: Category.Id, name: String, icon: String?) {
        self.id = id
        self.name = name
        self.icon = icon
    }

    public init(category: JoinedSubcategoriesServingStyles) {
        id = category.id
        name = category.name
        icon = category.icon
    }

    public init() {
        id = .init(rawValue: 0)
        name = ""
        icon = nil
    }
}

public extension Category {
    typealias Id = Tagged<Category, Int>
}

public extension Category {
    struct JoinedSubcategoriesServingStyles: Identifiable, Codable, Hashable, Sendable, CategoryProtocol {
        public let id: Category.Id
        public let name: String
        public let icon: String?
        public let subcategories: [Subcategory]
        public let servingStyles: [ServingStyle]

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case icon
            case subcategories
            case servingStyles = "serving_styles"
        }

        init(id: Category.Id, name: String, icon: String? = nil, subcategories: [Subcategory], servingStyles: [ServingStyle]) {
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

        public func copyWith(
            id: Category.Id? = nil,
            name: String? = nil,
            icon: String? = nil,
            subcategories: [Subcategory]? = nil,
            servingStyles: [ServingStyle]? = nil
        ) -> Self {
            .init(
                id: id ?? self.id,
                name: name ?? self.name,
                icon: icon ?? self.icon,
                subcategories: subcategories ?? self.subcategories,
                servingStyles: servingStyles ?? self.servingStyles
            )
        }

        public func appending(subcategory: Subcategory) -> JoinedSubcategoriesServingStyles {
            copyWith(subcategories: subcategories + [subcategory])
        }
    }

    struct Detailed: Identifiable, Codable, Hashable, Sendable, CategoryProtocol, ModificationInfo {
        public let id: Category.Id
        public let name: String
        public let icon: String?
        public let subcategories: [Subcategory]
        public let servingStyles: [ServingStyle]
        public let createdAt: Date
        public let createdBy: Profile?
        public let updatedAt: Date?
        public let updatedBy: Profile?

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case icon
            case subcategories
            case servingStyles = "serving_styles"
            case createdBy = "created_by"
            case createdAt = "created_at"
            case updatedBy = "updated_by"
            case updatedAt = "updated_at"
        }

        public func copyWith(
            id: Category.Id? = nil,
            name: String? = nil,
            icon: String? = nil,
            subcategories: [Subcategory]? = nil,
            servingStyles: [ServingStyle]? = nil
        ) -> Self {
            .init(
                id: id ?? self.id,
                name: name ?? self.name,
                icon: icon ?? self.icon,
                subcategories: subcategories ?? self.subcategories,
                servingStyles: servingStyles ?? self.servingStyles,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy
            )
        }

        public func appending(subcategory: Subcategory) -> Detailed {
            copyWith(subcategories: subcategories + [subcategory])
        }
    }

    struct NewRequest: Codable, Sendable {
        public init(name: String) {
            self.name = name
        }

        public let name: String
    }

    struct NewServingStyleRequest: Codable, Sendable {
        public init(categoryId: Category.Id, servingStyleId: Int) {
            self.categoryId = categoryId
            self.servingStyleId = servingStyleId
        }

        public let categoryId: Category.Id
        public let servingStyleId: Int

        enum CodingKeys: String, CodingKey {
            case categoryId = "category_id"
            case servingStyleId = "serving_style_id"
        }
    }
}
