struct Product: Identifiable, Decodable, Hashable {
    let id: Int
    let name: String
    let description: String?

    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Product {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = "products"
        let saved = "id, name, description"

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        case let .joinedBrandSubcategories(withTableName):
            return queryWithTableName(tableName, joinWithComma(saved, SubBrand.getQuery(.joinedBrand(true)), Category.getQuery(.saved(true)), Subcategory.getQuery(.joinedCategory(true)), ProductBarcode.getQuery(.saved(true))), withTableName)
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
        case joinedBrandSubcategories(_ withTableName: Bool)
    }
}

struct ProductJoined: Identifiable {
    let id: Int
    let name: String
    let description: String?
    let subBrand: SubBrandJoinedWithBrand
    let category: Category
    let subcategories: [SubcategoryJoinedWithCategory]
    let barcodes: [ProductBarcode]

    func getDisplayName(_ part: ProductNameParts) -> String {
        switch part {
        case .full:
            return [subBrand.brand.brandOwner.name, subBrand.brand.name, subBrand.name, name]
                .compactMap({ $0 })
                .joined(separator: " ")
        case .brandOwner:
            return subBrand.brand.brandOwner.name
        case .fullName:
            return [subBrand.brand.name, subBrand.name, name]
                .compactMap({ $0 })
                .joined(separator: " ")
        }
    }
}

extension ProductJoined {
    enum ProductNameParts {
        case brandOwner
        case fullName
        case full
    }
}

extension ProductJoined: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ProductJoined, rhs: ProductJoined) -> Bool {
        return lhs.id == rhs.id
    }
}

extension ProductJoined: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case subBrand = "sub_brands"
        case category = "categories"
        case subcategories
        case barcodes = "product_barcodes"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        subBrand = try values.decode(SubBrandJoinedWithBrand.self, forKey: .subBrand)
        category = try values.decode(Category.self, forKey: .category)
        subcategories = try values.decode([SubcategoryJoinedWithCategory].self, forKey: .subcategories)
        barcodes = try values.decode([ProductBarcode].self, forKey: .barcodes)
    }
}

extension ProductJoined {
    init(company: Company, product: ProductJoinedCategory, subBrand: SubBrandJoinedProduct, brand: BrandJoinedSubBrandsJoinedProduct) {
        id = product.id
        name = product.name
        description = product.name
        self.subBrand = SubBrandJoinedWithBrand(id: subBrand.id, name: subBrand.name, brand: BrandJoinedWithCompany(id: brand.id, name: brand.name, brandOwner: company))
        subcategories = product.subcategories
        category = product.category
        barcodes = []
    }
}

struct ProductJoinedCategory: Identifiable, Decodable, Hashable {
    let id: Int
    let name: String
    let description: String?
    let category: Category
    let subcategories: [SubcategoryJoinedWithCategory]

    static func == (lhs: ProductJoinedCategory, rhs: ProductJoinedCategory) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case category = "categories"
        case subcategories
    }

    init(id: Int, name: String, category: Category, description: String?, subcategories: [SubcategoryJoinedWithCategory]) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.subcategories = subcategories
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        category = try values.decode(Category.self, forKey: .category)
        subcategories = try values.decode([SubcategoryJoinedWithCategory].self, forKey: .subcategories)
    }
}

struct NewProductParams: Encodable {
    let p_name: String
    let p_description: String?
    let p_category_id: Int
    let p_brand_id: Int
    let p_sub_category_ids: [Int]
    let p_sub_brand_id: Int?
    let p_barcode_code: String?
    let p_barcode_type: String?

    init(name: String, description: String?, categoryId: Int, brandId: Int, subBrandId: Int?, subCategoryIds: [Int], barcode: Barcode?) {
        p_name = name
        p_description = description
        p_category_id = categoryId
        p_sub_brand_id = subBrandId
        p_sub_category_ids = subCategoryIds
        p_brand_id = brandId

        if let barcode = barcode {
            p_barcode_code = barcode.barcode
            p_barcode_type = barcode.type.rawValue
        } else {
            p_barcode_code = nil
            p_barcode_type = nil
        }
    }
}

struct NewProductEditSuggestionParams: Encodable {
    let p_product_id: Int
    let p_name: String
    let p_description: String?
    let p_category_id: Int
    let p_sub_category_ids: [Int]
    let p_sub_brand_id: Int?

    init(productId: Int, name: String, description: String?, categoryId: Int, subBrandId: Int?, subCategoryIds: [Int]) {
        p_product_id = productId
        p_name = name
        p_description = description
        p_category_id = categoryId
        p_sub_brand_id = subBrandId
        p_sub_category_ids = subCategoryIds
    }
}

struct GetProductSummaryParams: Encodable {
    let p_product_id: Int

    init(id: Int) {
        p_product_id = id
    }
}

struct ProductSummary {
    let totalCheckIns: Int
    let averageRating: Double?
    let friendsTotalCheckIns: Int
    let friendsAverageRating: Double?
    let currentUserTotalCheckIns: Int
    let currentUserAverageRating: Double?
}

extension ProductSummary: Decodable {
    enum CodingKeys: String, CodingKey {
        case totalCheckIns = "total_check_ins"
        case averageRating = "average_rating"
        case friendsTotalCheckIns = "friends_check_ins"
        case friendsAverageRating = "friends_average_rating"
        case currentUserTotalCheckIns = "current_user_check_ins"
        case currentUserAverageRating = "current_user_average_rating"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        totalCheckIns = try values.decode(Int.self, forKey: .totalCheckIns)
        averageRating = try values.decodeIfPresent(Double.self, forKey: .averageRating)
        friendsTotalCheckIns = try values.decode(Int.self, forKey: .friendsTotalCheckIns)
        friendsAverageRating = try values.decodeIfPresent(Double.self, forKey: .friendsAverageRating)
        currentUserTotalCheckIns = try values.decode(Int.self, forKey: .currentUserTotalCheckIns)
        currentUserAverageRating = try values.decodeIfPresent(Double.self, forKey: .currentUserAverageRating)
    }
}
