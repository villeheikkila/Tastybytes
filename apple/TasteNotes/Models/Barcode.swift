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

struct ProductBarcode: Identifiable, Hashable {
    let id: Int
    let barcode: String
    let type: AVMetadataObject.ObjectType
    
    func isBarcode(_ code: Barcode?) -> Bool {
        guard let code = code else { return false }
        return type == code.type && barcode == code.barcode
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
    struct New: Encodable {
        let barcode: String
        let type: String
        let product_id: Int
        
        init (product: ProductJoined, barcode: Barcode) {
            self.product_id = product.id
            self.type = barcode.type.rawValue
            self.barcode = barcode.barcode
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


struct ProductBarcodeJoined: Identifiable, Hashable {
    let id: Int
    let barcode: String
    let type: AVMetadataObject.ObjectType
    let product: ProductJoined
    
    func isBarcode(_ code: Barcode?) -> Bool {
        guard let code = code else { return false }
        return type == code.type && barcode == code.barcode
    }
}

extension ProductBarcodeJoined: Decodable {
    enum CodingKeys: String, CodingKey {
        case id, barcode, type, product = "products"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        barcode = try values.decode(String.self, forKey: .barcode)
        type = AVMetadataObject.ObjectType(rawValue: try values.decode(String.self, forKey: .type))
        product =  try values.decode(ProductJoined.self, forKey: .product)
    }
}

