import Extensions
import Foundation
import Tagged

public protocol SubcategoryProtocol {
    var id: Subcategory.Id { get }
    var name: String { get }
    var isVerified: Bool { get }
}

public struct Subcategory: Identifiable, Codable, Hashable, Sendable, SubcategoryProtocol, Comparable {
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

    public static func < (lhs: Subcategory, rhs: Subcategory) -> Bool {
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

public extension Subcategory {
    typealias Id = Tagged<Subcategory, Int>
}

public extension Subcategory {
    struct JoinedCategory: Identifiable, Hashable, Codable, Sendable, SubcategoryProtocol {
        public let id: Subcategory.Id
        public let name: String
        public let isVerified: Bool
        public let category: Category

        public init(id: Subcategory.Id, name: String, isVerified: Bool, category: Category) {
            self.id = id
            self.name = name
            self.isVerified = isVerified
            self.category = category
        }

        public init(category: Category, subcategory: Subcategory) {
            id = subcategory.id
            name = subcategory.name
            isVerified = subcategory.isVerified
            self.category = category
        }

        public func getSubcategory() -> Subcategory {
            Subcategory(id: id, name: name, isVerified: isVerified)
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case category = "categories"
        }

        public func copyWith(
            name: String? = nil,
            isVerified: Bool? = nil,
            category: Category? = nil
        ) -> Self {
            .init(
                id: id,
                name: name ?? self.name,
                isVerified: isVerified ?? self.isVerified,
                category: category ?? self.category
            )
        }
    }

    struct Detailed: Identifiable, Hashable, Codable, Sendable, SubcategoryProtocol, ModificationInfo {
        public let id: Subcategory.Id
        public let name: String
        public let isVerified: Bool
        public let category: Category
        public let createdAt: Date
        public let createdBy: Profile?
        public let updatedAt: Date?
        public let updatedBy: Profile?

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case category = "categories"
            case createdBy = "created_by"
            case createdAt = "created_at"
            case updatedBy = "updated_by"
            case updatedAt = "updated_at"
        }

        public func copyWith(
            name: String? = nil,
            isVerified: Bool? = nil,
            category: Category? = nil
        ) -> Self {
            .init(
                id: id,
                name: name ?? self.name,
                isVerified: isVerified ?? self.isVerified,
                category: category ?? self.category,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy
            )
        }
    }
}

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
