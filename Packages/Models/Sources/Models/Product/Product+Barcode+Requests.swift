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

        public init(id: Product.Id, barcode: Barcode) {
            productId = id
            type = barcode.type
            self.barcode = barcode.barcode
        }
    }
}
