import Foundation

public enum BrandLike {
    public struct New: Codable, Sendable {
        public init(brandId: Brand.Id) {
            self.brandId = brandId
        }

        public let brandId: Brand.Id

        enum CodingKeys: String, CodingKey {
            case brandId = "brand_id"
        }
    }

    public struct CheckIfLikedRequest: Codable, Sendable {
        public init(id: Brand.Id) {
            self.id = id
        }

        public let id: Brand.Id

        enum CodingKeys: String, CodingKey {
            case id = "p_brand_id"
        }
    }
}
