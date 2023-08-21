import Foundation

public enum ProfileWishlist {
    public struct Joined: Codable {
        public let createdBy: UUID
        public let product: Product.Joined

        enum CodingKeys: String, CodingKey {
            case createdBy = "created_by"
            case product = "products"
        }
    }

    public struct New: Codable {
        public init(productId: Int) {
            self.productId = productId
        }

        public let productId: Int

        enum CodingKeys: String, CodingKey {
            case productId = "product_id"
        }
    }

    public struct CheckIfOnWishlist: Codable {
        public init(id: Int) {
            self.id = id
        }

        public let id: Int

        enum CodingKeys: String, CodingKey {
            case id = "p_product_id"
        }
    }

    public static func getQuery(_ queryType: QueryType) -> String {
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

    public enum QueryType {
        case tableName
        case joined(_ withTableName: Bool)
    }
}
