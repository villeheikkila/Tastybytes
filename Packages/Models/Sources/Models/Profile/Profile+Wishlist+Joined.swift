import Foundation

public extension Profile {
    enum Wishlist {
        public struct Joined: Codable, Sendable {
            public let product: Product.Joined

            enum CodingKeys: String, CodingKey {
                case product = "products"
            }
        }
    }
}
