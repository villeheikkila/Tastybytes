import Foundation

public enum BrandLike {
    public struct New: Codable {
        public init(brandId: Int) {
            self.brandId = brandId
        }

        public let brandId: Int

        enum CodingKeys: String, CodingKey {
            case brandId = "brand_id"
        }
    }

    public struct CheckIfLikedRequest: Codable {
        public init(id: Int) {
            self.id = id
        }

        public let id: Int

        enum CodingKeys: String, CodingKey {
            case id = "p_brand_id"
        }
    }
}
