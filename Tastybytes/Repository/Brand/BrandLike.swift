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
}

