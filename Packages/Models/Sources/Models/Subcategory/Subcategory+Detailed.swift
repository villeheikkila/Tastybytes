import Extensions
import Foundation
public import Tagged

public extension Subcategory {
    struct Detailed: Identifiable, Hashable, Codable, Sendable, SubcategoryProtocol, ModificationInfo {
        public let id: Subcategory.Id
        public let name: String
        public let isVerified: Bool
        public let category: Category.Saved
        public let createdAt: Date
        public let createdBy: Profile.Saved?
        public let updatedAt: Date?
        public let updatedBy: Profile.Saved?

        init(
            id: Subcategory.Id,
            name: String,
            isVerified: Bool,
            category: Category.Saved,
            createdAt: Date,
            createdBy: Profile.Saved? = nil,
            updatedAt: Date? = nil,
            updatedBy: Profile.Saved? = nil
        ) {
            self.id = id
            self.name = name
            self.isVerified = isVerified
            self.category = category
            self.createdAt = createdAt
            self.createdBy = createdBy
            self.updatedAt = updatedAt
            self.updatedBy = updatedBy
        }

        public init() {
            id = .init(rawValue: 0)
            name = ""
            isVerified = false
            category = .init()
            createdAt = Date.now
            createdBy = nil
            updatedAt = nil
            updatedBy = nil
        }

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
            category: Category.Saved? = nil
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
