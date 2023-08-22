import Foundation

public struct Product: Identifiable, Codable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let description: String?
    public let isVerified: Bool
    public let isDiscontinued: Bool
    public let logoFile: String?

    enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case name
        case description
        case logoFile = "logo_file"
        case isVerified = "is_verified"
        case isDiscontinued = "is_discontinued"
    }
}

public extension Product {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = Database.Table.products.rawValue
        let saved = "id, name, description, logo_file, is_verified, is_discontinued"
        let logoBucketId = Database.Bucket.productLogos.rawValue

        switch queryType {
        case .tableName:
            return tableName
        case .logoBucket:
            return logoBucketId
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        case let .joinedBrandSubcategories(withTableName):
            return queryWithTableName(
                tableName,
                [saved, SubBrand.getQuery(.joinedBrand(true)), Category.getQuery(.saved(true)),
                 Subcategory.getQuery(.joinedCategory(true)), ProductBarcode.getQuery(.saved(true))].joinComma(),
                withTableName
            )
        case let .joinedBrandSubcategoriesCreator(withTableName):
            return queryWithTableName(
                tableName,
                [
                    saved,
                    "created_at",
                    SubBrand.getQuery(.joinedBrand(true)),
                    Category.getQuery(.saved(true)),
                    Subcategory.getQuery(.joinedCategory(true)),
                    ProductBarcode.getQuery(.saved(true)),
                ].joinComma(),
                withTableName
            )
        case let .joinedBrandSubcategoriesRatings(withTableName):
            return queryWithTableName(
                tableName,
                [
                    saved,
                    "current_user_check_ins",
                    "average_rating",
                    SubBrand.getQuery(.joinedBrand(true)),
                    Category.getQuery(.saved(true)),
                    Subcategory.getQuery(.joinedCategory(true)),
                    ProductBarcode.getQuery(.saved(true)),
                ].joinComma(),
                withTableName
            )
        case let .joinedBrandSubcategoriesProfileRatings(withTableName):
            return queryWithTableName(
                tableName,
                [
                    saved,
                    "check_ins",
                    "average_rating",
                    SubBrand.getQuery(.joinedBrand(true)),
                    Category.getQuery(.saved(true)),
                    Subcategory.getQuery(.joinedCategory(true)),
                    ProductBarcode.getQuery(.saved(true)),
                ].joinComma(),
                withTableName
            )
        }
    }

    enum QueryType {
        case tableName
        case logoBucket
        case saved(_ withTableName: Bool)
        case joinedBrandSubcategories(_ withTableName: Bool)
        case joinedBrandSubcategoriesCreator(_ withTableName: Bool)
        case joinedBrandSubcategoriesRatings(_ withTableName: Bool)
        case joinedBrandSubcategoriesProfileRatings(_ withTableName: Bool)
    }
}

public struct ProductDuplicateSuggestion {
    let product: Product.Joined
    let duplicateOf: Product.Joined

    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = "product_duplicate_suggestions"
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

public extension Product {
    struct SearchParams: Codable, Sendable {
        public let searchTerm: String
        public let categoryName: String?
        public let subCategoryId: Int?
        public let onlyNonCheckedIn: Bool

        enum CodingKeys: String, CodingKey {
            case searchTerm = "p_search_term"
            case categoryName = "p_category_name"
            case subCategoryId = "p_subcategory_id"
            case onlyNonCheckedIn = "p_only_non_checked_in"
        }

        public init(searchTerm: String, filter: Filter?) {
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

    struct EditRequest: Codable, Sendable {
        let productId: Int
        let name: String
        let description: String?
        let categoryId: Int
        let subcategoryIds: [Int]
        let subBrandId: Int
        let isDiscontinued: Bool

        enum CodingKeys: String, CodingKey {
            case productId = "p_product_id"
            case name = "p_name"
            case description = "p_description"
            case categoryId = "p_category_id"
            case subcategoryIds = "p_sub_category_ids"
            case subBrandId = "p_sub_brand_id"
            case isDiscontinued = "p_is_discontinued"
        }

        public init(
            productId: Int,
            name: String,
            description: String?,
            categoryId: Int,
            subBrandId: Int,
            subcategories: [Subcategory],
            isDiscontinued: Bool
        ) {
            self.productId = productId
            self.name = name
            self.description = description
            self.categoryId = categoryId
            self.subBrandId = subBrandId
            self.isDiscontinued = isDiscontinued
            subcategoryIds = subcategories.map(\.id)
        }
    }

    struct Filter: Hashable, Codable {
        public enum SortBy: String, CaseIterable, Identifiable, Sendable, Codable {
            public var id: Self { self }

            case highestRated = "highest_rated"
            case lowestRated = "lowest_rated"

            public var label: String {
                switch self {
                case .highestRated:
                    "Highest Rated First"
                case .lowestRated:
                    "Lowest Rated First"
                }
            }
        }

        public let category: Models.Category.JoinedSubcategoriesServingStyles?
        public let subcategory: Subcategory?
        public let onlyNonCheckedIn: Bool
        public let sortBy: SortBy?
        public let rating: Double?
        public let onlyUnrated: Bool?

        public init(category: Models.Category.JoinedSubcategoriesServingStyles? = nil,
                    subcategory: Subcategory? = nil,
                    onlyNonCheckedIn: Bool = false,
                    sortBy: SortBy? = nil,
                    rating: Double? = nil,
                    onlyUnrated: Bool? = nil)
        {
            self.category = category
            self.subcategory = subcategory
            self.onlyNonCheckedIn = onlyNonCheckedIn
            self.sortBy = sortBy
            self.rating = rating
            self.onlyUnrated = onlyUnrated
        }

        public init(rating: Double) {
            self.rating = rating
            onlyNonCheckedIn = false
            category = nil
            subcategory = nil
            sortBy = nil
            onlyUnrated = nil
        }

        public init(
            category: Models.Category.JoinedSubcategoriesServingStyles?,
            subcategory: Subcategory?,
            onlyNonCheckedIn: Bool,
            sortBy: SortBy?
        ) {
            self.category = category
            self.subcategory = subcategory
            self.onlyNonCheckedIn = onlyNonCheckedIn
            self.sortBy = sortBy
            rating = nil
            onlyUnrated = nil
        }

        public init(category: Category?, subcategory: Subcategory?, onlyNonCheckedIn: Bool, sortBy: SortBy?) {
            if let category {
                self.category = Models.Category.JoinedSubcategoriesServingStyles(
                    id: category.id,
                    name: category.name,
                    icon: category.icon,
                    subcategories: [],
                    servingStyles: []
                )
            } else {
                self.category = nil
            }
            self.subcategory = subcategory
            self.onlyNonCheckedIn = onlyNonCheckedIn
            self.sortBy = sortBy
            rating = nil
            onlyUnrated = nil
        }

        public func copyWith(category: Models.Category.JoinedSubcategoriesServingStyles?) -> Filter {
            Filter(category: category, subcategory: subcategory, onlyNonCheckedIn: onlyNonCheckedIn, sortBy: sortBy)
        }

        public func copyWith(subcategory: Subcategory?) -> Filter {
            Filter(category: category, subcategory: subcategory, onlyNonCheckedIn: onlyNonCheckedIn, sortBy: sortBy)
        }

        public func copyWith(onlyNonCheckedIn: Bool) -> Filter {
            Filter(category: category, subcategory: subcategory, onlyNonCheckedIn: onlyNonCheckedIn, sortBy: sortBy)
        }

        public func copyWith(sortBy: SortBy?) -> Filter {
            Filter(category: category, subcategory: subcategory, onlyNonCheckedIn: onlyNonCheckedIn, sortBy: sortBy)
        }
    }

    struct MergeProductsParams: Codable, Sendable {
        public init(productId: Int, toProductId: Int) {
            self.productId = productId
            self.toProductId = toProductId
        }

        public let productId: Int
        public let toProductId: Int

        enum CodingKeys: String, CodingKey {
            case productId = "p_product_id", toProductId = "p_to_product_id"
        }
    }

    struct NewRequest: Codable, Sendable {
        public let name: String
        public let description: String?
        public let categoryId: Int
        public let brandId: Int
        public let subCategoryIds: [Int]
        public let subBrandId: Int?
        public let barcodeCode: String?
        public let barcodeType: String?
        public let isDiscontinued: Bool

        enum CodingKeys: String, CodingKey {
            case name = "p_name"
            case description = "p_description"
            case categoryId = "p_category_id"
            case brandId = "p_brand_id"
            case subCategoryIds = "p_sub_category_ids"
            case subBrandId = "p_sub_brand_id"
            case barcodeCode = "p_barcode_code"
            case barcodeType = "p_barcode_type"
            case isDiscontinued = "p_is_discontinued"
        }

        public init(
            name: String,
            description: String?,
            categoryId: Int,
            brandId: Int,
            subBrandId: Int?,
            subCategoryIds: [Int],
            isDiscontinued: Bool,
            barcode: Barcode?
        ) {
            self.name = name
            self.description = description
            self.categoryId = categoryId
            self.subBrandId = subBrandId
            self.subCategoryIds = subCategoryIds
            self.brandId = brandId
            self.isDiscontinued = isDiscontinued

            if let barcode {
                barcodeCode = barcode.barcode
                barcodeType = barcode.type
            } else {
                barcodeCode = nil
                barcodeType = nil
            }
        }
    }

    struct DuplicateRequest: Codable, Sendable {
        public init(productId: Int, duplicateOfProductId: Int) {
            self.productId = productId
            self.duplicateOfProductId = duplicateOfProductId
        }

        public let productId: Int
        public let duplicateOfProductId: Int

        enum CodingKeys: String, CodingKey {
            case productId = "product_id"
            case duplicateOfProductId = "duplicate_of_product_id"
        }
    }

    struct SummaryRequest: Codable, Sendable {
        public init(id: Int) {
            self.id = id
        }

        public let id: Int

        enum CodingKeys: String, CodingKey {
            case id = "p_product_id"
        }
    }

    struct VerifyRequest: Codable, Sendable {
        public init(id: Int, isVerified: Bool) {
            self.id = id
            self.isVerified = isVerified
        }

        public let id: Int
        public let isVerified: Bool

        enum CodingKeys: String, CodingKey {
            case id = "p_product_id"
            case isVerified = "p_is_verified"
        }
    }
}

public extension Product {
    enum NameParts {
        case brandOwner
        case fullName
        case full
    }

    enum FeedType: Hashable, Identifiable, Codable {
        public var id: String { label }

        case topRated, trending, latest

        public var label: String {
            switch self {
            case .topRated:
                return "Top Rated"
            case .trending:
                return "Trending"
            case .latest:
                return "Latest"
            }
        }
    }

    struct Joined: Identifiable, Hashable, Codable, Sendable {
        public let id: Int
        public let name: String
        public let description: String?
        public let logoFile: String?
        public let isVerified: Bool
        public let subBrand: SubBrand.JoinedBrand
        public let category: Category
        public let subcategories: [Subcategory.JoinedCategory]
        public let barcodes: [ProductBarcode]
        public let averageRating: Double?
        public let currentUserCheckIns: Int?
        public let createdBy: Profile?
        public let createdAt: String?
        public let isDiscontinued: Bool

        public var logoUrl: URL? {
            guard let logoFile else { return nil }
            return URL(bucketId: Product.getQuery(.logoBucket), fileName: logoFile)
        }

        public func getDisplayName(_ part: NameParts) -> String {
            switch part {
            case .full:
                return [
                    subBrand.brand.brandOwner.name,
                    subBrand.brand.name,
                    subBrand.name,
                    name,
                    isDiscontinued ? "(discontinued)" : nil,
                ]
                    .joinOptionalSpace()
            case .brandOwner:
                return subBrand.brand.brandOwner.name
            case .fullName:
                return [subBrand.brand.name, subBrand.name, name, isDiscontinued ? "(discontinued)" : nil]
                    .joinOptionalSpace()
            }
        }

        enum CodingKeys: String, CodingKey, Sendable {
            case id
            case name
            case description
            case logoFile = "logo_file"
            case isVerified = "is_verified"
            case subBrand = "sub_brands"
            case category = "categories"
            case subcategories
            case barcodes = "product_barcodes"
            case averageRating = "average_rating"
            case currentUserCheckIns = "current_user_check_ins"
            case createdBy = "profiles"
            case createdAt = "created_at"
            case isDiscontinued = "is_discontinued"
        }

        public init(
            id: Int,
            name: String,
            description: String,
            logoFile: String?,
            isVerified: Bool,
            subBrand: SubBrand.JoinedBrand,
            category: Category,
            subcategories: [Subcategory.JoinedCategory],
            barcodes: [ProductBarcode],
            isDiscontinued: Bool
        ) {
            self.id = id
            self.name = name
            self.description = description
            self.logoFile = logoFile
            self.isVerified = isVerified
            self.subBrand = subBrand
            self.subcategories = subcategories
            self.category = category
            self.barcodes = barcodes
            self.isDiscontinued = isDiscontinued
            currentUserCheckIns = nil
            averageRating = nil
            createdBy = nil
            createdAt = nil
        }

        public init(
            company: Company,
            product: Product.JoinedCategory,
            subBrand: SubBrand.JoinedProduct,
            brand: Brand.JoinedSubBrandsProducts
        ) {
            id = product.id
            name = product.name
            description = product.description
            logoFile = product.logoFile
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
            isDiscontinued = product.isDiscontinued
        }

        public init(
            product: Product.JoinedCategory,
            subBrand: SubBrand.JoinedProduct,
            brand: Brand.JoinedSubBrandsProductsCompany
        ) {
            id = product.id
            name = product.name
            description = product.description
            logoFile = product.logoFile
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
            isDiscontinued = product.isDiscontinued
        }
    }

    struct EditSuggestionRequest: Codable, Sendable {
        public let id: Int?
        public let name: String?
        public let description: String?
        public let subBrandId: Int?
        public let categoryId: Int?
        public let isDiscontinued: Bool?

        public init(
            id: Int?,
            name: String?,
            description: String?,
            subBrand: SubBrandProtocol?,
            category: CategoryProtocol?,
            isDiscontinued: Bool?
        ) {
            self.id = id
            self.name = name
            self.description = description?.isEmpty ?? true ? nil : description
            subBrandId = subBrand?.id
            categoryId = category?.id
            self.isDiscontinued = isDiscontinued
        }

        public init(
            id: Int? = nil,
            name: String? = nil,
            description: String? = nil,
            subBrandId: Int? = nil,
            categoryId: Int? = nil,
            isDiscontinued: Bool? = nil
        ) {
            self.id = id
            self.name = name
            self.description = description
            self.subBrandId = subBrandId
            self.categoryId = categoryId
            self.isDiscontinued = isDiscontinued
        }

        enum CodingKeys: String, CodingKey {
            case id = "product_id"
            case name
            case description
            case categoryId = "category_id"
            case subBrandId = "sub_brand_id"
            case isDiscontinued = "is_discontinued"
        }

        public func diff(from joined: Joined) -> EditSuggestionRequest? {
            let diff = EditSuggestionRequest(
                id: id,
                name: joined.name == name ? nil : name,
                description: joined.description == description ? nil : description,
                subBrandId: joined.subBrand.id == subBrandId ? nil : subBrandId,
                categoryId: joined.category.id == categoryId ? nil : categoryId,
                isDiscontinued: joined.isDiscontinued == isDiscontinued ? nil : isDiscontinued
            )

            return diff.name != nil || diff.description != nil || diff.subBrandId != nil || diff
                .categoryId != nil || diff.isDiscontinued != nil ? diff : nil
        }
    }

    struct JoinedCategory: Identifiable, Codable, Hashable, Sendable {
        public let id: Int
        public let name: String
        public let description: String?
        public let logoFile: String?
        public let isVerified: Bool
        public let isDiscontinued: Bool
        public let category: Category
        public let subcategories: [Subcategory.JoinedCategory]

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case description
            case logoFile = "logo_file"
            case isVerified = "is_verified"
            case isDiscontinued = "is_discontinued"
            case category = "categories"
            case subcategories
        }

        public init(
            id: Int,
            name: String,
            description: String?,
            logoFile: String?,
            isVerified: Bool,
            isDiscontinued: Bool,
            category: Category,
            subcategories: [Subcategory.JoinedCategory]
        ) {
            self.id = id
            self.name = name
            self.description = description
            self.logoFile = logoFile
            self.isVerified = isVerified
            self.category = category
            self.subcategories = subcategories
            self.isDiscontinued = isDiscontinued
        }
    }
}

extension CaseIterable where Self: RawRepresentable, Self.RawValue == String {
    static var allValues: [String] {
        return allCases.map { $0.rawValue }
    }
}
