import Foundation

public enum ProfileWishlist {
    public struct Joined: Codable, Sendable {
        public let product: Product.Joined

        enum CodingKeys: String, CodingKey {
            case product = "products"
        }
    }

    public struct New: Codable, Sendable {
        public init(productId: Int) {
            self.productId = productId
        }

        public let productId: Int

        enum CodingKeys: String, CodingKey {
            case productId = "product_id"
        }
    }

    public struct CheckIfOnWishlist: Codable, Sendable {
        public init(id: Int) {
            self.id = id
        }

        public let id: Int

        enum CodingKeys: String, CodingKey {
            case id = "p_product_id"
        }
    }
}
