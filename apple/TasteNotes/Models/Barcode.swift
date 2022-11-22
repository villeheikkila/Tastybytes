import AVFoundation

struct Barcode: Encodable, Hashable {
    let barcode: String
    let type: AVMetadataObject.ObjectType
    
    enum CodingKeys: String, CodingKey {
        case barcode, type
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(barcode, forKey: .barcode)
        try container.encode(type.rawValue, forKey: .type)
    }
}

struct ProductBarcode: Identifiable {
    let id: Int
    let barcode: String
    let type: AVMetadataObject.ObjectType
    
    func isBarcode(_ code: Barcode?) -> Bool {
        guard let code = code else { return false }
        return type == code.type && barcode == code.barcode
    }
}

extension ProductBarcode: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ProductBarcode, rhs: ProductBarcode) -> Bool {
        return lhs.id == rhs.id
    }
}

extension ProductBarcode: Decodable {
    enum CodingKeys: String, CodingKey {
        case id, barcode, type
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        barcode = try values.decode(String.self, forKey: .barcode)
        type = AVMetadataObject.ObjectType(rawValue: try values.decode(String.self, forKey: .type))
    }
}

extension ProductBarcode {
    struct NewRequest: Encodable {
        let barcode: String
        let type: String
        let product_id: Int
        
        init (product: Product.Joined, barcode: Barcode) {
            self.product_id = product.id
            self.type = barcode.type.rawValue
            self.barcode = barcode.barcode
        }
    }
    
    struct Joined: Identifiable, Hashable, Decodable {
        let id: Int
        let barcode: String
        let type: AVMetadataObject.ObjectType
        let product: Product.Joined
        
        func isBarcode(_ code: Barcode?) -> Bool {
            guard let code = code else { return false }
            return type == code.type && barcode == code.barcode
        }
        
        enum CodingKeys: String, CodingKey {
            case id, barcode, type, product = "products"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(Int.self, forKey: .id)
            barcode = try values.decode(String.self, forKey: .barcode)
            type = AVMetadataObject.ObjectType(rawValue: try values.decode(String.self, forKey: .type))
            product =  try values.decode(Product.Joined.self, forKey: .product)
        }
    }
}

extension ProductBarcode {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = "product_barcodes"
        let saved = "id, barcode, type"
        
        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        case let .joined(withTableName):
            return queryWithTableName(tableName, joinWithComma(saved, Product.getQuery(.joinedBrandSubcategories(true))), withTableName)
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
        case joined(_ withTableName: Bool)
    }
}
