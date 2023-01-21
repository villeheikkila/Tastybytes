enum Brand {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "brands"
    let saved = "id, name, is_verified"

    switch queryType {
    case .tableName:
      return tableName
    case let .joinedSubBrands(withTableName):
      return queryWithTableName(tableName, joinWithComma(saved, SubBrand.getQuery(.saved(true))), withTableName)
    case let .joined(withTableName):
      return queryWithTableName(tableName, joinWithComma(saved, SubBrand.getQuery(.joined(true))), withTableName)
    case let .joinedCompany(withTableName):
      return queryWithTableName(tableName, joinWithComma(saved, Company.getQuery(.saved(true))), withTableName)
    }
  }

  enum QueryType {
    case tableName
    case joined(_ withTableName: Bool)
    case joinedSubBrands(_ withTableName: Bool)
    case joinedCompany(_ withTableName: Bool)
  }
}

extension Brand {
  struct JoinedSubBrands: Identifiable, Hashable, Decodable {
    let id: Int
    let name: String
    let isVerified: Bool
    let subBrands: [SubBrand]

    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    static func == (lhs: JoinedSubBrands, rhs: JoinedSubBrands) -> Bool {
      lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
      case id
      case name
      case isVerified = "is_verified"
      case subBrands = "sub_brands"
    }

    init(id: Int, name: String, isVerified: Bool, subBrands: [SubBrand]) {
      self.id = id
      self.name = name
      self.isVerified = isVerified
      self.subBrands = subBrands
    }

    init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      id = try values.decode(Int.self, forKey: .id)
      name = try values.decode(String.self, forKey: .name)
      isVerified = try values.decode(Bool.self, forKey: .isVerified)
      subBrands = try values.decode([SubBrand].self, forKey: .subBrands)
    }
  }

  struct JoinedCompany: Identifiable, Hashable, Decodable {
    let id: Int
    let name: String
    let isVerified: Bool
    let brandOwner: Company

    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    static func == (lhs: JoinedCompany, rhs: JoinedCompany) -> Bool {
      lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
      case id
      case name
      case isVerified = "is_verified"
      case brandOwner = "companies"
    }

    init(id: Int, name: String, isVerified: Bool, brandOwner: Company) {
      self.id = id
      self.name = name
      self.isVerified = isVerified
      self.brandOwner = brandOwner
    }

    init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      id = try values.decode(Int.self, forKey: .id)
      name = try values.decode(String.self, forKey: .name)
      isVerified = try values.decode(Bool.self, forKey: .isVerified)
      brandOwner = try values.decode(Company.self, forKey: .brandOwner)
    }
  }

  struct JoinedSubBrandsProducts: Identifiable, Hashable, Decodable {
    let id: Int
    let name: String
    let isVerified: Bool
    let subBrands: [SubBrand.JoinedProduct]

    func getNumberOfProducts() -> Int {
      subBrands.flatMap(\.products).count
    }

    static func == (lhs: JoinedSubBrandsProducts, rhs: JoinedSubBrandsProducts) -> Bool {
      lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
      case id
      case name
      case isVerified = "is_verified"
      case subBrands = "sub_brands"
    }

    init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      id = try values.decode(Int.self, forKey: .id)
      name = try values.decode(String.self, forKey: .name)
      isVerified = try values.decode(Bool.self, forKey: .isVerified)
      subBrands = try values.decode([SubBrand.JoinedProduct].self, forKey: .subBrands)
    }
  }
}

extension Brand {
  struct NewRequest: Encodable {
    let name: String
    let brand_owner_id: Int

    init(name: String, brandOwnerId: Int) {
      self.name = name
      brand_owner_id = brandOwnerId
    }
  }

  struct UpdateRequest: Encodable {
    let id: Int
    let name: String
    let brand_owner_id: Int

    init(id: Int, name: String, brandOwnerId: Int) {
      self.id = id
      self.name = name
      brand_owner_id = brandOwnerId
    }
  }
}
