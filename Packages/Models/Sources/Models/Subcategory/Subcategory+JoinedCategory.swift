import Extensions
import Foundation
public import Tagged

public extension Subcategory {
    struct JoinedCategory: Identifiable, Hashable, Codable, Sendable, SubcategoryProtocol {
        public let id: Subcategory.Id
        public let name: String
        public let isVerified: Bool
        public let category: Category.Saved

        public init(id: Subcategory.Id, name: String, isVerified: Bool, category: Category.Saved) {
            self.id = id
            self.name = name
            self.isVerified = isVerified
            self.category = category
        }

        public init(category: Category.Saved, subcategory: Subcategory.Saved) {
            id = subcategory.id
            name = subcategory.name
            isVerified = subcategory.isVerified
            self.category = category
        }

        public func getSubcategory() -> Subcategory.Saved {
            Subcategory.Saved(id: id, name: name, isVerified: isVerified)
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
            category: Category.Saved? = nil
        ) -> Self {
            .init(
                id: id,
                name: name ?? self.name,
                isVerified: isVerified ?? self.isVerified,
                category: category ?? self.category
            )
        }
    }
}
