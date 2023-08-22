import Extensions
import Foundation

public struct Barcode: Codable, Hashable, Sendable {
    enum CodingKeys: String, CodingKey {
        case barcode, type
    }

    public let barcode: String
    public let type: String

    public init(barcode: String, type: String) {
        self.barcode = barcode
        self.type = type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        barcode = try container.decode(String.self, forKey: .barcode)
        type = try container.decode(String.self, forKey: .type)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(barcode, forKey: .barcode)
        try container.encode(type, forKey: .type)
    }
}

public struct ProductBarcode: Identifiable, Hashable, Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case id, barcode, type
    }

    public let id: Int
    public let barcode: String
    public let type: String

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        barcode = try values.decode(String.self, forKey: .barcode)
        type = try values.decode(String.self, forKey: .type)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(barcode, forKey: .barcode)
        try container.encode(type, forKey: .type)
    }

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
            case id, barcode, type, profiles, createdAt = "created_at"
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(Int.self, forKey: .id)
            barcode = try values.decode(String.self, forKey: .barcode)
            type = try values.decode(String.self, forKey: .type)
            profile = try values.decode(Profile.self, forKey: .profiles)
            let timestamp = try values.decode(String.self, forKey: .createdAt)
            if let createdAt = Date(timestamptzString: timestamp) {
                self.createdAt = createdAt
            } else {
                throw DateParsingError.unsupportedFormat
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(barcode, forKey: .barcode)
            try container.encode(type, forKey: .type)
            try container.encode(profile, forKey: .profiles)
            try container.encode(createdAt, forKey: .createdAt)
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

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(Int.self, forKey: .id)
            barcode = try values.decode(String.self, forKey: .barcode)
            type = try values.decode(String.self, forKey: .type)
            product = try values.decode(Product.Joined.self, forKey: .product)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(barcode, forKey: .barcode)
            try container.encode(type, forKey: .type)
            try container.encode(product, forKey: .product)
        }
    }
}

public extension ProductBarcode {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.productBarcodes.rawValue
        let saved = "id, barcode, type"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        case let .joined(withTableName):
            return queryWithTableName(
                tableName,
                [saved, Product.getQuery(.joinedBrandSubcategories(true))].joinComma(),
                withTableName
            )
        case let .joinedCreator(withTableName):
            return queryWithTableName(
                tableName,
                [saved, "created_at", Profile.getQuery(.minimal(true))].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
        case joined(_ withTableName: Bool)
        case joinedCreator(_ withTableName: Bool)
    }
}
