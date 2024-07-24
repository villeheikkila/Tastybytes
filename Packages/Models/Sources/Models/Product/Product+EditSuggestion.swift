import Foundation
public import Tagged

public extension Product {
    struct EditSuggestion: Identifiable, Codable, Hashable, Sendable, Resolvable, CreationInfo {
        public typealias Id = Tagged<Product.EditSuggestion, Int>

        public let id: Product.EditSuggestion.Id
        public let product: Product.Joined
        public let duplicateOf: Product.Joined?
        public let createdAt: Date
        public let createdBy: Profile
        public let name: String?
        public let description: String?
        public let category: Category.Saved?
        public let subBrand: SubBrand.JoinedBrand?
        public let subcategoryEditSuggestions: [SubcategoryEditSuggestion]
        public let isDiscontinued: Bool?
        public let resolvedAt: Date?

        enum CodingKeys: String, CodingKey {
            case id
            case product = "products"
            case duplicateOf = "duplicate_of"
            case createdAt = "created_at"
            case createdBy = "profiles"
            case name
            case description
            case category = "categories"
            case subBrand = "sub_brands"
            case subcategoryEditSuggestions = "product_edit_suggestion_subcategories"
            case isDiscontinued = "is_discontinued"
            case resolvedAt = "resolved_at"
        }

        public func copyWith(resolvedAt: Date?) -> Self {
            .init(
                id: id,
                product: product,
                duplicateOf: duplicateOf,
                createdAt: createdAt,
                createdBy: createdBy,
                name: name,
                description: description,
                category: category,
                subBrand: subBrand,
                subcategoryEditSuggestions: subcategoryEditSuggestions,
                isDiscontinued: isDiscontinued,
                resolvedAt: resolvedAt ?? self.resolvedAt
            )
        }

        public struct SubcategoryEditSuggestion: Identifiable, Codable, Hashable, Sendable {
            public let id: Product.EditSuggestion.SubcategoryEditSuggestion.Id
            public let subcategory: Subcategory.JoinedCategory
            public let delete: Bool

            enum CodingKeys: String, CodingKey {
                case id
                case subcategory = "subcategories"
                case delete
            }

            public typealias Id = Tagged<SubcategoryEditSuggestion, Int>
        }
    }
}
