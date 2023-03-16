struct Product: Identifiable, Decodable, Hashable, Sendable {
  let id: Int
  let name: String
  let description: String?
  let isVerified: Bool

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
    case let .joinedBrandSubcategoriesCreator(withTableName):
      return queryWithTableName(
        tableName,
        joinWithComma(
          saved,
          "created_at",
          SubBrand.getQuery(.joinedBrand(true)),
          Category.getQuery(.saved(true)),
          Subcategory.getQuery(.joinedCategory(true)),
          ProductBarcode.getQuery(.saved(true))
        ),
        withTableName
      )
    case let .joinedBrandSubcategoriesRatings(withTableName):
      return queryWithTableName(
        tableName,
        joinWithComma(
          saved,
          "current_user_check_ins",
          "average_rating",
          SubBrand.getQuery(.joinedBrand(true)),
          Category.getQuery(.saved(true)),
          Subcategory.getQuery(.joinedCategory(true)),
          ProductBarcode.getQuery(.saved(true))
        ),
        withTableName
      )
    case let .joinedBrandSubcategoriesProfileRatings(withTableName):
      return queryWithTableName(
        tableName,
        joinWithComma(
          saved,
          "check_ins",
          "average_rating",
          SubBrand.getQuery(.joinedBrand(true)),
          Category.getQuery(.saved(true)),
          Subcategory.getQuery(.joinedCategory(true)),
          ProductBarcode.getQuery(.saved(true))
        ),
        withTableName
      )
    }
  }

  enum QueryType {
    case tableName
    case saved(_ withTableName: Bool)
    case joinedBrandSubcategories(_ withTableName: Bool)
    case joinedBrandSubcategoriesCreator(_ withTableName: Bool)
    case joinedBrandSubcategoriesRatings(_ withTableName: Bool)
    case joinedBrandSubcategoriesProfileRatings(_ withTableName: Bool)
  }
}

struct ProductDuplicateSuggestion {
  let product: Product.Joined
  let duplicateOf: Product.Joined

  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "product_edit_suggestion_subcategories"
    let saved = "product_id, duplicate_of_product_id"

    switch queryType {
    case .tableName:
      return tableName
    case let .saved(withTableName):
      return queryWithTableName(tableName, saved, withTableName)
    }
  }

  enum QueryType {
    case tableName
    case saved(_ withTableName: Bool)
  }
}

extension Product {
  struct SearchParams: Encodable, Sendable {
    let searchTerm: String
    let categoryName: String?
    let subCategoryId: Int?
    let onlyNonCheckedIn: Bool

    enum CodingKeys: String, CodingKey {
      case searchTerm = "p_search_term"
      case categoryName = "p_category_name"
      case subCategoryId = "p_subcategory_id"
      case onlyNonCheckedIn = "p_only_non_checked_in"
    }

    init(searchTerm: String, filter: Filter?) {
      self.searchTerm = "\(searchTerm.trimmingCharacters(in: .whitespacesAndNewlines))"

      if let filter {
        categoryName = filter.category?.name
        subCategoryId = filter.subcategory?.id
        onlyNonCheckedIn = filter.onlyNonCheckedIn

      } else {
        categoryName = nil
        subCategoryId = nil
        onlyNonCheckedIn = false
      }
    }
  }

  struct Filter {
    enum SortBy: String, CaseIterable, Identifiable, Sendable {
      var id: Self { self }
      case highestRated = "highest_rated"
      case lowestRated = "lowest_rated"

      var label: String {
        switch self {
        case .highestRated:
          return "Highest Rated First"
        case .lowestRated:
          return "Lowest Rated First"
        }
      }
    }

    let category: Category.JoinedSubcategories?
    let subcategory: Subcategory?
    let onlyNonCheckedIn: Bool
    let sortBy: SortBy?
  }

  struct MergeProductsParams: Encodable, Sendable {
    let productId: Int
    let toProductId: Int?

    enum CodingKeys: String, CodingKey {
      case productId = "p_product_id", toProductId = "p_to_product_id"
    }
  }

  struct NewRequest: Encodable, Sendable {
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

  struct DuplicateRequest: Encodable, Sendable {
    let productId: Int
    let duplicateOfProductId: Int

    enum CodingKeys: String, CodingKey {
      case productId = "product_id"
      case duplicateOfProductId = "duplicate_of_product_id"
    }
  }

  struct EditRequest: Encodable, Sendable {
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

  struct EditSuggestionRequest: Encodable, Sendable {
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

  struct SummaryRequest: Encodable, Sendable {
    let id: Int

    enum CodingKeys: String, CodingKey {
      case id = "p_product_id"
    }
  }

  struct VerifyRequest: Encodable, Sendable {
    let id: Int
    let isVerified: Bool

    enum CodingKeys: String, CodingKey {
      case id = "p_product_id"
      case isVerified = "p_is_verified"
    }
  }
}

extension Product {
  enum NameParts {
    case brandOwner
    case fullName
    case full
  }

  struct Joined: Identifiable, Hashable, Decodable, Sendable {
    let id: Int
    let name: String
    let description: String?
    let isVerified: Bool
    let subBrand: SubBrand.JoinedBrand
    let category: Category
    let subcategories: [Subcategory.JoinedCategory]
    let barcodes: [ProductBarcode]
    let averageRating: Double?
    let currentUserCheckIns: Int?
    let createdBy: Profile?
    let createdAt: String?

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

    enum CodingKeys: String, CodingKey, Sendable {
      case id
      case name
      case description
      case isVerified = "is_verified"
      case subBrand = "sub_brands"
      case category = "categories"
      case subcategories
      case barcodes = "product_barcodes"
      case averageRating = "average_rating"
      case currentUserCheckIns = "current_user_check_ins"
      case createdBy = "profiles"
      case createdAt = "created_at"
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
      currentUserCheckIns = nil
      averageRating = nil
      createdBy = nil
      createdAt = nil
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
        brand: Brand.JoinedCompany(
          id: brand.id,
          name: brand.name,
          logoFile: brand.logoFile,
          isVerified: brand.isVerified,
          brandOwner: company
        )
      )
      subcategories = product.subcategories
      category = product.category
      barcodes = []
      currentUserCheckIns = nil
      averageRating = nil
      createdBy = nil
      createdAt = nil
    }

    init(
      product: Product.JoinedCategory,
      subBrand: SubBrand.JoinedProduct,
      brand: Brand.JoinedSubBrandsProductsCompany
    ) {
      id = product.id
      name = product.name
      description = product.description
      isVerified = product.isVerified
      self.subBrand = SubBrand.JoinedBrand(
        id: subBrand.id,
        name: subBrand.name,
        isVerified: subBrand.isVerified,
        brand: Brand.JoinedCompany(
          id: brand.id,
          name: brand.name,
          logoFile: brand.logoFile,
          isVerified: brand.isVerified,
          brandOwner: brand.brandOwner
        )
      )
      subcategories = product.subcategories
      category = product.category
      barcodes = []
      currentUserCheckIns = nil
      averageRating = nil
      createdBy = nil
      createdAt = nil
    }
  }

  struct JoinedCategory: Identifiable, Decodable, Hashable, Sendable {
    let id: Int
    let name: String
    let description: String?
    let isVerified: Bool
    let category: Category
    let subcategories: [Subcategory.JoinedCategory]

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
}
