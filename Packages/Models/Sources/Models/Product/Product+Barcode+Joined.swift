import Foundation
public import Tagged

public extension Product.Barcode {
    struct Joined: Identifiable, Hashable, Codable, Sendable {
        public let id: Product.Barcode.Id
        public let barcode: String
        public let type: String
        public let product: Product.Joined

        public func isBarcode(_ code: Barcode?) -> Bool {
            guard let code else { return false }
            return type == code.type && barcode == code.barcode
        }

        enum CodingKeys: String, CodingKey {
            case id, barcode, type, product = "products"
        }
    }
}
