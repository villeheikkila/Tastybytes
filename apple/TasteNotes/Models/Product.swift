struct Product: Identifiable, Decodable, Hashable {
    let id: Int
    let name: String
    let description: String?
    let isVerified: Bool

    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case isVerified = "is_verified"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        isVerified = try values.decode(Bool.self, forKey: .isVerified)
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
            return queryWithTableName(tableName, joinWithComma(saved, SubBrand.getQuery(.joinedBrand(true)), Category.getQuery(.saved(true)), Subcategory.getQuery(.joinedCategory(true)), ProductBarcode.getQuery(.saved(true))), withTableName)
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
        let p_search_term: String
        let p_category_name: String?

        init(searchTerm: String, categoryName: Category.Name?) {
            p_search_term = "%\(searchTerm.trimmingCharacters(in: .whitespacesAndNewlines))%"

            if let categoryName = categoryName {
                p_category_name = categoryName.rawValue
            } else {
                p_category_name = nil
            }
        }
    }
    
    struct MergeProductsParams: Encodable {
        let p_product_id: Int
        let p_to_product_id: Int?

        init(productId: Int, toProductId: Int) {
            p_product_id = productId
            p_to_product_id = toProductId
        }
    }

    struct NewRequest: Encodable {
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

    struct EditSuggestionRequest: Encodable {
        let p_product_id: Int
        let p_name: String
        let p_description: String?
        let p_category_id: Int
        let p_sub_category_ids: [Int]
        let p_sub_brand_id: Int

        init(productId: Int, name: String, description: String?, categoryId: Int, subBrandId: Int, subCategoryIds: [Int]) {
            p_product_id = productId
            p_name = name
            p_description = description
            p_category_id = categoryId
            p_sub_brand_id = subBrandId
            p_sub_category_ids = subCategoryIds
        }
    }

    struct SummaryRequest: Encodable {
        let p_product_id: Int

        init(id: Int) {
            p_product_id = id
        }
    }
    
    struct VerifyRequest: Encodable {
        let p_product_id: Int

        init(id: Int) {
            p_product_id = id
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

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        static func == (lhs: Joined, rhs: Joined) -> Bool {
            return lhs.id == rhs.id
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
        
        init(id: Int, name: String, description: String, isVerified: Bool, subBrand: SubBrand.JoinedBrand, category: Category, subcategories: [Subcategory.JoinedCategory], barcodes: [ProductBarcode]) {
            self.id = id
            self.name = name
            self.description = description
            self.isVerified = isVerified
            self.subBrand = subBrand
            self.subcategories = subcategories
            self.category = category
            self.barcodes = barcodes
        }

        init(company: Company, product: Product.JoinedCategory, subBrand: SubBrand.JoinedProduct, brand: Brand.JoinedSubBrandsProducts) {
            id = product.id
            name = product.name
            description = product.name
            isVerified = product.isVerified
            self.subBrand = SubBrand.JoinedBrand(id: subBrand.id, name: subBrand.name, isVerified: subBrand.isVerified, brand: Brand.JoinedCompany(id: brand.id, name: brand.name, isVerified: brand.isVerified, brandOwner: company))
            subcategories = product.subcategories
            category = product.category
            barcodes = []
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(Int.self, forKey: .id)
            name = try values.decode(String.self, forKey: .name)
            description = try values.decodeIfPresent(String.self, forKey: .description)
            isVerified = try values.decode(Bool.self, forKey: .isVerified)
            subBrand = try values.decode(SubBrand.JoinedBrand.self, forKey: .subBrand)
            category = try values.decode(Category.self, forKey: .category)
            subcategories = try values.decode([Subcategory.JoinedCategory].self, forKey: .subcategories)
            barcodes = try values.decode([ProductBarcode].self, forKey: .barcodes)
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
            return lhs.id == rhs.id
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case description
            case isVerified = "is_verified"
            case category = "categories"
            case subcategories
        }

        init(id: Int, name: String, category: Category, description: String?, isVerified: Bool, subcategories: [Subcategory.JoinedCategory]) {
            self.id = id
            self.name = name
            self.description = description
            self.isVerified = isVerified
            self.category = category
            self.subcategories = subcategories
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(Int.self, forKey: .id)
            name = try values.decode(String.self, forKey: .name)
            description = try values.decodeIfPresent(String.self, forKey: .description)
            isVerified = try values.decode(Bool.self, forKey: .isVerified)
            category = try values.decode(Category.self, forKey: .category)
            subcategories = try values.decode([Subcategory.JoinedCategory].self, forKey: .subcategories)
        }
    }

    enum NameParts {
        case brandOwner
        case fullName
        case full
    }
}

struct ProductSummary: Decodable {
    let totalCheckIns: Int
    let averageRating: Double?
    let friendsTotalCheckIns: Int
    let friendsAverageRating: Double?
    let currentUserTotalCheckIns: Int
    let currentUserAverageRating: Double?
    
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
