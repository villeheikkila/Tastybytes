import Foundation
public import Tagged

public extension Product.Barcode {
    struct Saved: Identifiable, Hashable, Codable, Sendable, BarcodeProtocol {
        enum CodingKeys: String, CodingKey {
            case id, barcode, type
        }

        public let id: Product.Barcode.Id
        public let barcode: String
        public let type: String

        public init(barcode: Product.Barcode.JoinedWithCreator) {
            id = barcode.id
            self.barcode = barcode.barcode
            type = barcode.type
        }
    }
}
