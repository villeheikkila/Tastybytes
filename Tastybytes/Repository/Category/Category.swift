protocol CategoryProtocol {
    var id: Int { get }
    var name: String { get }
    var icon: String { get }
}

extension CategoryProtocol {
    var label: String {
        "\(icon) \(name)"
    }
}

struct Category: Identifiable, Codable, Hashable, CategoryProtocol {
    let id: Int
    let name: String
    let icon: String
}

extension Category {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.categories.rawValue
        let servingStyleTableName = Database.Table.categoryServingStyles.rawValue
        let saved = "id, name, icon"

        switch queryType {
        case .tableName:
            return tableName
        case .servingStyleTableName:
            return servingStyleTableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        case let .joinedSubcaategoriesServingStyles(withTableName):
            return queryWithTableName(
                tableName,
                [saved, Subcategory.getQuery(.saved(true)), ServingStyle.getQuery(.saved(true))].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case servingStyleTableName
        case saved(_ withTableName: Bool)
        case joinedSubcaategoriesServingStyles(_ withTableName: Bool)
    }
}

extension Category {
    struct JoinedSubcategoriesServingStyles: Identifiable, Codable, Hashable, Sendable, CategoryProtocol {
        let id: Int
        let name: String
        let icon: String
        let subcategories: [Subcategory]
        let servingStyles: [ServingStyle]

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case icon
            case subcategories
            case servingStyles = "serving_styles"
        }

        func copyWith(
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

        func appending(subcategory: Subcategory) -> JoinedSubcategoriesServingStyles {
            let newSubcategories = subcategories + [subcategory]
            return copyWith(subcategories: newSubcategories)
        }
    }

    struct NewRequest: Codable, Sendable {
        let name: String
    }

    struct NewServingStyleRequest: Codable, Sendable {
        let categoryId: Int
        let servingStyleId: Int

        enum CodingKeys: String, CodingKey {
            case categoryId = "category_id"
            case servingStyleId = "serving_style_id"
        }
    }
}
