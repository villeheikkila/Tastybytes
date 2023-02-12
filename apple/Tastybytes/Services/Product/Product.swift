struct Product: Identifiable, Decodable, Hashable {
  let id: Int
  let name: String
  let description: String?
  let isVerified: Bool

  static func == (lhs: Product, rhs: Product) -> Bool {
    lhs.id == rhs.id && lhs.name == rhs.name && lhs.description == rhs.description && lhs.isVerified == rhs.isVerified
  }

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case description
    case isVerified = "is_verified"
  }
}

extension Product {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "products"
    let saved = "id, name, description, is_verified"

    switch queryType {
    case .tableName:
      return tableName
    case let .saved(withTableName):
      return queryWithTableName(tableName, saved, withTableName)
    case let .joinedBrandSubcategories(withTableName):
      return queryWithTableName(
        tableName,
        joinWithComma(saved, SubBrand.getQuery(.joinedBrand(true)), Category.getQuery(.saved(true)),
                      Subcategory.getQuery(.joinedCategory(true)), ProductBarcode.getQuery(.saved(true))),
        withTableName
      )
    }
  }

  enum QueryType {
    case tableName
    case saved(_ withTableName: Bool)
    case joinedBrandSubcategories(_ withTableName: Bool)
  }
}

extension Product {
  struct SearchParams: Encodable {
    let searchTerm: String
    let categoryName: String?

    enum CodingKeys: String, CodingKey {
      case searchTerm = "p_search_term", categoryName = "p_category_name"
    }

    init(searchTerm: String, categoryName: Category.Name?) {
      self.searchTerm = "%\(searchTerm.trimmingCharacters(in: .whitespacesAndNewlines))%"

      if let categoryName {
        self.categoryName = categoryName.rawValue
      } else {
        self.categoryName = nil
      }
    }
  }

  struct MergeProductsParams: Encodable {
    let productId: Int
    let toProductId: Int?

    enum CodingKeys: String, CodingKey {
      case productId = "p_product_id", toProductId = "p_to_product_id"
    }
  }

  struct NewRequest: Encodable {
    let name: String
    let description: String?
    let categoryId: Int
    let brandId: Int
    let subCategoryIds: [Int]
    let subBrandId: Int?
    let barcodeCode: String?
    let barcodeType: String?

    enum CodingKeys: String, CodingKey {
      case name = "p_name"
      case description = "p_description"
      case categoryId = "p_category_id"
      case brandId = "p_brand_id"
      case subCategoryIds = "p_sub_category_ids"
      case subBrandId = "p_sub_brand_id"
      case barcodeCode = "p_barcode_code"
      case barcodeType = "p_barcode_type"
    }

    init(
      name: String,
      description: String?,
      categoryId: Int,
      brandId: Int,
      subBrandId: Int?,
      subCategoryIds: [Int],
      barcode: Barcode?
    ) {
      self.name = name
      self.description = description
      self.categoryId = categoryId
      self.subBrandId = subBrandId
      self.subCategoryIds = subCategoryIds
      self.brandId = brandId

      if let barcode {
        barcodeCode = barcode.barcode
        barcodeType = barcode.type.rawValue
      } else {
        barcodeCode = nil
        barcodeType = nil
      }
    }
  }

  struct EditRequest: Encodable {
    let productId: Int
    let name: String
    let description: String?
    let categoryId: Int
    let subcategoryIds: [Int]
    let subBrandId: Int

    enum CodingKeys: String, CodingKey {
      case productId = "p_product_id"
      case name = "p_name"
      case description = "p_description"
      case categoryId = "p_category_id"
      case subcategoryIds = "p_sub_category_ids"
      case subBrandId = "p_sub_brand_id"
    }

    init(
      productId: Int,
      name: String,
      description: String?,
      categoryId: Int,
      subBrandId: Int,
      subcategories: [Subcategory]
    ) {
      self.productId = productId
      self.name = name
      self.description = description
      self.categoryId = categoryId
      self.subBrandId = subBrandId
      subcategoryIds = subcategories.map(\.id)
    }
  }

  struct EditSuggestionRequest: Encodable {
    let productId: Int
    let name: String
    let description: String?
    let categoryId: Int
    let subcategoryIds: [Int]
    let subBrandId: Int

    enum CodingKeys: String, CodingKey {
      case productId = "p_product_id"
      case name = "p_name"
      case description = "p_description"
      case categoryId = "p_category_id"
      case subcategoryIds = "p_sub_category_ids"
      case subBrandId = "p_sub_brand_id"
    }
  }

  struct SummaryRequest: Encodable {
    let id: Int

    enum CodingKeys: String, CodingKey {
      case id = "p_product_id"
    }
  }

  struct VerifyRequest: Encodable {
    let id: Int
    let isVerified: Bool

    enum CodingKeys: String, CodingKey {
      case id = "p_product_id"
      case isVerified = "p_is_verified"
    }
  }
}

extension Product {
  struct Joined: Identifiable, Hashable, Decodable {
    let id: Int
    let name: String
    let description: String?
    let isVerified: Bool
    let subBrand: SubBrand.JoinedBrand
    let category: Category
    let subcategories: [Subcategory.JoinedCategory]
    let barcodes: [ProductBarcode]

    func getDisplayName(_ part: NameParts) -> String {
      switch part {
      case .full:
        return [subBrand.brand.brandOwner.name, subBrand.brand.name, subBrand.name, name]
          .compactMap { $0 }
          .joined(separator: " ")
      case .brandOwner:
        return subBrand.brand.brandOwner.name
      case .fullName:
        return [subBrand.brand.name, subBrand.name, name]
          .compactMap { $0 }
          .joined(separator: " ")
      }
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
      hasher.combine(name)
      hasher.combine(description)
      hasher.combine(isVerified)
      hasher.combine(subBrand.id)
      hasher.combine(subBrand.name)
    }

    static func == (lhs: Joined, rhs: Joined) -> Bool {
      lhs.id == rhs.id && lhs.name == rhs.name && lhs.description == rhs.description && lhs.isVerified == rhs
        .isVerified && lhs.subBrand.name == rhs.subBrand.name
    }

    enum CodingKeys: String, CodingKey {
      case id
      case name
      case description
      case isVerified = "is_verified"
      case subBrand = "sub_brands"
      case category = "categories"
      case subcategories
      case barcodes = "product_barcodes"
    }

    init(
      id: Int,
      name: String,
      description: String,
      isVerified: Bool,
      subBrand: SubBrand.JoinedBrand,
      category: Category,
      subcategories: [Subcategory.JoinedCategory],
      barcodes: [ProductBarcode]
    ) {
      self.id = id
      self.name = name
      self.description = description
      self.isVerified = isVerified
      self.subBrand = subBrand
      self.subcategories = subcategories
      self.category = category
      self.barcodes = barcodes
    }

    init(
      company: Company,
      product: Product.JoinedCategory,
      subBrand: SubBrand.JoinedProduct,
      brand: Brand.JoinedSubBrandsProducts
    ) {
      id = product.id
      name = product.name
      description = product.description
      isVerified = product.isVerified
      self.subBrand = SubBrand.JoinedBrand(
        id: subBrand.id,
        name: subBrand.name,
        isVerified: subBrand.isVerified,
        brand: Brand.JoinedCompany(id: brand.id, name: brand.name, isVerified: brand.isVerified, brandOwner: company)
      )
      subcategories = product.subcategories
      category = product.category
      barcodes = []
    }

    init(
      product: Product.JoinedCategory,
      subBrand: SubBrand.JoinedProduct,
      brand: Brand.JoinedSubBrandsProductsCompany
    ) {
      id = product.id
      name = product.name
      description = product.name
      isVerified = product.isVerified
      self.subBrand = SubBrand.JoinedBrand(
        id: subBrand.id,
        name: subBrand.name,
        isVerified: subBrand.isVerified,
        brand: Brand.JoinedCompany(
          id: brand.id,
          name: brand.name,
          isVerified: brand.isVerified,
          brandOwner: brand.brandOwner
        )
      )
      subcategories = product.subcategories
      category = product.category
      barcodes = []
    }
  }

  struct JoinedCategory: Identifiable, Decodable, Hashable {
    let id: Int
    let name: String
    let description: String?
    let isVerified: Bool
    let category: Category
    let subcategories: [Subcategory.JoinedCategory]

    static func == (lhs: JoinedCategory, rhs: JoinedCategory) -> Bool {
      lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
      case id
      case name
      case description
      case isVerified = "is_verified"
      case category = "categories"
      case subcategories
    }

    init(
      id: Int,
      name: String,
      category: Category,
      description: String?,
      isVerified: Bool,
      subcategories: [Subcategory.JoinedCategory]
    ) {
      self.id = id
      self.name = name
      self.description = description
      self.isVerified = isVerified
      self.category = category
      self.subcategories = subcategories
    }
  }

  enum NameParts {
    case brandOwner
    case fullName
    case full
  }
}
