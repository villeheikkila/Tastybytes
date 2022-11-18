import AVFoundation

struct Barcode: Encodable {
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
    let product: ProductJoined
}

extension ProductBarcode: Decodable {
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

extension ProductBarcode {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = "product_barcodes"
        let saved = "id, barcode, type"
        
        switch queryType {
        case .tableName:
            return tableName
        case let .joined(withTableName):
            return queryWithTableName(tableName, joinWithComma(saved, Product.getQuery(.joinedBrandSubcategories(true))), withTableName)
        }
    }

    enum QueryType {
        case tableName
        case joined(_ withTableName: Bool)
    }
}
