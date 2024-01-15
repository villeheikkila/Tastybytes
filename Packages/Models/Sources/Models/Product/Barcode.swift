import Extensions
import Foundation

public struct Barcode: Codable, Hashable, Sendable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case barcode, type
    }

    public let barcode: String
    public let type: String

    public init(barcode: String, type: String) {
        self.barcode = barcode
        self.type = type
    }

    public var id: String {
        "\(type)_\(barcode)"
    }
}

public struct ProductBarcode: Identifiable, Hashable, Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case id, barcode, type
    }

    public let id: Int
    public let barcode: String
    public let type: String

    public func isBarcode(_ code: Barcode?) -> Bool {
        guard let code else { return false }
        return type == code.type && barcode == code.barcode
    }
}

public extension ProductBarcode {
    struct NewRequest: Codable, Sendable {
        enum CodingKeys: String, CodingKey {
            case barcode, type, productId = "product_id"
        }

        public let barcode: String
        public let type: String
        public let productId: Int

        public init(product: Product.Joined, barcode: Barcode) {
            productId = product.id
            type = barcode.type
            self.barcode = barcode.barcode
        }
    }

    struct JoinedWithCreator: Identifiable, Hashable, Codable, Sendable {
        public let id: Int
        public let barcode: String
        public let type: String
        public let profile: Profile
        public let createdAt: Date

        enum CodingKeys: String, CodingKey {
            case id, barcode, type, profile = "profile", createdAt = "created_at"
        }
    }

    struct Joined: Identifiable, Hashable, Codable, Sendable {
        public let id: Int
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
