import AVFoundation

struct Barcode: Encodable, Hashable, Sendable {
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

struct ProductBarcode: Identifiable, Hashable, Decodable, Sendable {
  let id: Int
  let barcode: String
  let type: AVMetadataObject.ObjectType

  func isBarcode(_ code: Barcode?) -> Bool {
    guard let code else { return false }
    return type == code.type && barcode == code.barcode
  }

  enum CodingKeys: String, CodingKey {
    case id, barcode, type
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(Int.self, forKey: .id)
    barcode = try values.decode(String.self, forKey: .barcode)
    type = try AVMetadataObject.ObjectType(rawValue: values.decode(String.self, forKey: .type))
  }
}

extension ProductBarcode {
  struct NewRequest: Encodable, Sendable {
    let barcode: String
    let type: String
    let productId: Int

    enum CodingKeys: String, CodingKey {
      case barcode, type, productId = "product_id"
    }

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
      createdAt = try parseDate(from: values.decode(String.self, forKey: .createdAt))
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
        joinWithComma(saved, Product.getQuery(.joinedBrandSubcategories(true))),
        withTableName
      )
    case let .joinedCreator(withTableName):
      return queryWithTableName(
        tableName,
        joinWithComma(saved, "created_at", Profile.getQuery(.minimal(true))),
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
