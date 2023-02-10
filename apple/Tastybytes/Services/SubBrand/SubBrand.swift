struct SubBrand: Identifiable, Hashable, Decodable {
  let id: Int
  let name: String?
  let isVerified: Bool

  init(id: Int, name: String?, isVerified: Bool) {
    self.id = id
    self.name = name
    self.isVerified = isVerified
  }

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case isVerified = "is_verified"
  }
}

extension SubBrand {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "sub_brands"
    let saved = "id, name, is_verified"

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
    case let .joinedBrand(withTableName):
      return queryWithTableName(tableName, joinWithComma(saved, Brand.getQuery(.joinedCompany(true))), withTableName)
    }
  }

  enum QueryType {
    case tableName
    case saved(_ withTableName: Bool)
    case joined(_ withTableName: Bool)
    case joinedBrand(_ withTableName: Bool)
  }
}

extension SubBrand {
  struct JoinedBrand: Identifiable, Hashable, Decodable {
    let id: Int
    let name: String?
    let isVerified: Bool
    let brand: Brand.JoinedCompany

    func getSubBrand() -> SubBrand {
      SubBrand(id: id, name: name, isVerified: isVerified)
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    static func == (lhs: JoinedBrand, rhs: JoinedBrand) -> Bool {
      lhs.id == rhs.id
    }

    init(id: Int, name: String?, isVerified: Bool, brand: Brand.JoinedCompany) {
      self.id = id
      self.name = name
      self.brand = brand
      self.isVerified = isVerified
    }

    enum CodingKeys: String, CodingKey {
      case id
      case name
      case brand = "brands"
      case isVerified = "is_verified"
    }
  }

  struct JoinedProduct: Identifiable, Hashable, Decodable {
    let id: Int
    let name: String?
    let isVerified: Bool
    let products: [Product.JoinedCategory]

    enum CodingKeys: String, CodingKey {
      case id
      case name
      case isVerified = "is_verified"
      case products
    }
  }
}

extension SubBrand {
  struct NewRequest: Encodable {
    let name: String
    let brandId: Int

    enum CodingKeys: String, CodingKey {
      case name
      case brandId = "brand_id"
    }

    init(name: String, brandId: Int) {
      self.name = name
      self.brandId = brandId
    }
  }

  struct UpdateNameRequest: Encodable {
    let id: Int
    let name: String

    init(id: Int, name: String) {
      self.id = id
      self.name = name
    }
  }

  struct UpdateBrandRequest: Encodable {
    let id: Int
    let brandId: Int

    enum CodingKeys: String, CodingKey {
      case id, brandId = "brand_id"
    }

    init(id: Int, brandId: Int) {
      self.id = id
      self.brandId = brandId
    }
  }

  struct VerifyRequest: Encodable {
    let id: Int

    enum CodingKeys: String, CodingKey {
      case id = "p_sub_brand_id"
    }
  }

  enum Update {
    case brand(UpdateBrandRequest)
    case name(UpdateNameRequest)
  }
}
