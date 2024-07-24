import Foundation
public import Tagged

public extension Product.Barcode {
    struct NewRequest: Codable, Sendable {
        enum CodingKeys: String, CodingKey {
            case barcode, type, productId = "product_id"
        }

        public let barcode: String
        public let type: String
        public let productId: Product.Id

        public init(product: ProductProtocol, barcode: Barcode) {
            productId = product.id
            type = barcode.type
            self.barcode = barcode.barcode
        }
    }
}
