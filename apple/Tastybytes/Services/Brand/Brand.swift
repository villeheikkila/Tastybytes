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
    case let .joinedSubBrandsCompany(withTableName):
      return queryWithTableName(
        tableName,
        joinWithComma(saved, SubBrand.getQuery(.joined(true)), Company.getQuery(.saved(true))),
        withTableName
      )
    }
  }

  enum QueryType {
    case tableName
    case joined(_ withTableName: Bool)
    case joinedSubBrands(_ withTableName: Bool)
    case joinedCompany(_ withTableName: Bool)
    case joinedSubBrandsCompany(_ withTableName: Bool)
  }
}

extension Brand {
  struct JoinedSubBrands: Identifiable, Hashable, Decodable, Sendable {
    let id: Int
    let name: String
    let logoFile: String?
    let isVerified: Bool
    let subBrands: [SubBrand]

    enum CodingKeys: String, CodingKey {
      case id
      case name
      case logoFile = "logo_file"
      case isVerified = "is_verified"
      case subBrands = "sub_brands"
    }
  }

  struct JoinedCompany: Identifiable, Hashable, Decodable, Sendable {
    let id: Int
    let name: String
    let logoFile: String?
    let isVerified: Bool
    let brandOwner: Company

    enum CodingKeys: String, CodingKey {
      case id
      case name
      case logoFile = "logo_file"
      case isVerified = "is_verified"
      case brandOwner = "companies"
    }
  }

  struct JoinedSubBrandsProducts: Identifiable, Hashable, Decodable, Sendable {
    let id: Int
    let name: String
    let logoFile: String?
    let isVerified: Bool
    let subBrands: [SubBrand.JoinedProduct]

    func getNumberOfProducts() -> Int {
      subBrands.flatMap(\.products).count
    }

    enum CodingKeys: String, CodingKey {
      case id
      case name
      case logoFile = "logo_file"
      case isVerified = "is_verified"
      case subBrands = "sub_brands"
    }
  }

  struct JoinedSubBrandsProductsCompany: Identifiable, Hashable, Decodable, Sendable {
    let id: Int
    let name: String
    let logoFile: String?
    let isVerified: Bool
    let brandOwner: Company
    let subBrands: [SubBrand.JoinedProduct]

    init(brandOwner: Company, brand: JoinedSubBrandsProducts) {
      id = brand.id
      name = brand.name
      isVerified = brand.isVerified
      self.brandOwner = brandOwner
      logoFile = brand.logoFile
      subBrands = brand.subBrands
    }

    func getNumberOfProducts() -> Int {
      subBrands.flatMap(\.products).count
    }

    init(id: Int, name: String, isVerified: Bool, brandOwner: Company, subBrands: [SubBrand.JoinedProduct]) {
      self.id = id
      self.name = name
      self.isVerified = isVerified
      self.brandOwner = brandOwner
      self.subBrands = subBrands
      logoFile = nil
    }

    enum CodingKeys: String, CodingKey {
      case id
      case name
      case logoFile = "logo_file"
      case isVerified = "is_verified"
      case brandOwner = "companies"
      case subBrands = "sub_brands"
    }
  }
}

extension Brand {
  struct NewRequest: Encodable, Sendable {
    let name: String
    let brandOwnerId: Int

    enum CodingKeys: String, CodingKey {
      case name, brandOwnerId = "brand_owner_id"
    }

    init(name: String, brandOwnerId: Int) {
      self.name = name
      self.brandOwnerId = brandOwnerId
    }
  }

  struct UpdateRequest: Encodable, Sendable {
    let id: Int
    let name: String
    let brandOwnerId: Int

    enum CodingKeys: String, CodingKey {
      case id, name, brandOwnerId = "brand_owner_id"
    }

    init(id: Int, name: String, brandOwnerId: Int) {
      self.id = id
      self.name = name
      self.brandOwnerId = brandOwnerId
    }
  }

  struct VerifyRequest: Encodable, Sendable {
    let id: Int
    let isVerified: Bool

    enum CodingKeys: String, CodingKey {
      case id = "p_brand_id"
      case isVerified = "p_is_verified"
    }
  }
}
