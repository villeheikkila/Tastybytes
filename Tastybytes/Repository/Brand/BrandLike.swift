import Foundation

enum BrandLike {
    struct New: Codable {
        let brandId: Int

        enum CodingKeys: String, CodingKey {
            case brandId = "brand_id"
        }
    }

    struct CheckIfLikedRequest: Codable {
        let id: Int

        enum CodingKeys: String, CodingKey {
            case id = "p_brand_id"
        }
    }

    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = "brand_likes"

        switch queryType {
        case .tableName:
            return tableName
        }
    }

    enum QueryType {
        case tableName
    }
}
