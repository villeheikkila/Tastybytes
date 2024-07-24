import Foundation
public import Tagged

public extension Category {
    struct Detailed: Identifiable, Codable, Hashable, Sendable, CategoryProtocol, ModificationInfo {
        public let id: Category.Id
        public let name: String
        public let icon: String?
        public let subcategories: [Subcategory.Saved]
        public let servingStyles: [ServingStyle.Saved]
        public let createdAt: Date
        public let createdBy: Profile?
        public let updatedAt: Date?
        public let updatedBy: Profile?

        init(
            id: Category.Id,
            name: String,
            icon: String? = nil,
            subcategories: [Subcategory.Saved],
            servingStyles: [ServingStyle.Saved],
            createdAt: Date,
            createdBy: Profile? = nil,
            updatedAt: Date? = nil,
            updatedBy: Profile? = nil
        ) {
            self.id = id
            self.name = name
            self.icon = icon
            self.subcategories = subcategories
            self.servingStyles = servingStyles
            self.createdAt = createdAt
            self.createdBy = createdBy
            self.updatedAt = updatedAt
            self.updatedBy = updatedBy
        }

        public init() {
            id = 0
            name = ""
            icon = nil
            subcategories = []
            servingStyles = []
            createdAt = Date.now
            createdBy = nil
            updatedAt = nil
            updatedBy = nil
        }

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
            subcategories: [Subcategory.Saved]? = nil,
            servingStyles: [ServingStyle.Saved]? = nil
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

        public func appending(subcategory: Subcategory.Saved) -> Detailed {
            copyWith(subcategories: subcategories + [subcategory])
        }
    }
}
