import Foundation

enum ProfileWishlist {
    struct Joined: Codable {
        let createdBy: UUID
        let product: Product.Joined

        enum CodingKeys: String, CodingKey {
            case createdBy = "created_by"
            case product = "products"
        }
    }

    struct New: Codable {
        let productId: Int

        enum CodingKeys: String, CodingKey {
            case productId = "product_id"
        }
    }

    struct CheckIfOnWishlist: Codable {
        let id: Int

        enum CodingKeys: String, CodingKey {
            case id = "p_product_id"
        }
    }

    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.profileWishlistItems.rawValue
        let saved = "created_by"

        switch queryType {
        case .tableName:
            return tableName
        case let .joined(withTableName):
            return queryWithTableName(
                tableName,
                [saved, Product.getQuery(.joinedBrandSubcategories(true))].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case joined(_ withTableName: Bool)
    }
}
