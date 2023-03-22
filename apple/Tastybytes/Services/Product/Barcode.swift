import AVFoundation

struct Barcode: Encodable, Hashable, Sendable {
  enum CodingKeys: String, CodingKey {
    case barcode, type
  }

  let barcode: String
  let type: AVMetadataObject.ObjectType

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(barcode, forKey: .barcode)
    try container.encode(type.rawValue, forKey: .type)
  }
}

struct ProductBarcode: Identifiable, Hashable, Decodable, Sendable {
  enum CodingKeys: String, CodingKey {
    case id, barcode, type
  }

  let id: Int
  let barcode: String
  let type: AVMetadataObject.ObjectType

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(Int.self, forKey: .id)
    barcode = try values.decode(String.self, forKey: .barcode)
    type = try AVMetadataObject.ObjectType(rawValue: values.decode(String.self, forKey: .type))
  }

  func isBarcode(_ code: Barcode?) -> Bool {
    guard let code else { return false }
    return type == code.type && barcode == code.barcode
  }
}

extension ProductBarcode {
  struct NewRequest: Encodable, Sendable {
    enum CodingKeys: String, CodingKey {
      case barcode, type, productId = "product_id"
    }

    let barcode: String
    let type: String
    let productId: Int

    init(product: Product.Joined, barcode: Barcode) {
      productId = product.id
      type = barcode.type.rawValue
      self.barcode = barcode.barcode
    }
  }

  struct JoinedWithCreator: Identifiable, Hashable, Decodable, Sendable {
    let id: Int
    let barcode: String
    let type: AVMetadataObject.ObjectType
    let profile: Profile
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
      case id, barcode, type, profiles, createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      id = try values.decode(Int.self, forKey: .id)
      barcode = try values.decode(String.self, forKey: .barcode)
      type = try AVMetadataObject.ObjectType(rawValue: values.decode(String.self, forKey: .type))
      profile = try values.decode(Profile.self, forKey: .profiles)
      let timestamp = try values.decode(String.self, forKey: .createdAt)
      if let createdAt = Date(timestamptzString: timestamp) {
        self.createdAt = createdAt
      } else {
        throw DateParsingError.unsupportedFormat
      }
    }
  }

  struct Joined: Identifiable, Hashable, Decodable, Sendable {
    let id: Int
    let barcode: String
    let type: AVMetadataObject.ObjectType
    let product: Product.Joined

    func isBarcode(_ code: Barcode?) -> Bool {
      guard let code else { return false }
      return type == code.type && barcode == code.barcode
    }

    enum CodingKeys: String, CodingKey {
      case id, barcode, type, product = "products"
    }

    init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      id = try values.decode(Int.self, forKey: .id)
      barcode = try values.decode(String.self, forKey: .barcode)
      type = try AVMetadataObject.ObjectType(rawValue: values.decode(String.self, forKey: .type))
      product = try values.decode(Product.Joined.self, forKey: .product)
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
