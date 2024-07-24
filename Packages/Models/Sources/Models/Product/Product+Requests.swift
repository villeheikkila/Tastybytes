import Foundation
public import Tagged

public extension Product {
    struct SearchParams: Codable, Sendable {
        public let searchTerm: String
        public let categoryName: String?
        public let subCategoryId: Subcategory.Id?
        public let onlyNonCheckedIn: Bool

        enum CodingKeys: String, CodingKey {
            case searchTerm = "p_search_term"
            case categoryName = "p_category_name"
            case subCategoryId = "p_subcategory_id"
            case onlyNonCheckedIn = "p_only_non_checked_in"
        }

        public init(searchTerm: String, filter: Filter?) {
            // Truncate multiple spaces to one and trim the ends
            self.searchTerm = searchTerm
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .split(separator: " ")
                .map { String($0) }
                .joined(separator: " ")

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
        let productId: Product.Id
        let name: String?
        let description: String?
        let categoryId: Category.Id
        let subcategoryIds: [Subcategory.Id]
        let subBrandId: SubBrand.Id
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
            productId: Product.Id,
            name: String?,
            description: String?,
            categoryId: Category.Id,
            subBrandId: SubBrand.Id,
            subcategories: [Subcategory.Saved],
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

    struct MergeProductsParams: Codable, Sendable {
        public init(productId: Product.Id, toProductId: Product.Id) {
            self.productId = productId
            self.toProductId = toProductId
        }

        public let productId: Product.Id
        public let toProductId: Product.Id

        enum CodingKeys: String, CodingKey {
            case productId = "p_product_id", toProductId = "p_to_product_id"
        }
    }

    struct NewRequest: Codable, Sendable {
        public let name: String?
        public let description: String?
        public let categoryId: Category.Id
        public let brandId: Brand.Id
        public let subCategoryIds: [Subcategory.Id]
        public let subBrandId: SubBrand.Id?
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
            categoryId: Category.Id,
            brandId: Brand.Id,
            subBrandId: SubBrand.Id?,
            subcategories: [Subcategory.Saved],
            isDiscontinued: Bool,
            barcode: BarcodeProtocol?
        ) {
            self.name = name
            self.description = description
            self.categoryId = categoryId
            self.subBrandId = subBrandId
            subCategoryIds = subcategories.map(\.id)
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

    struct VerifyRequest: Codable, Sendable {
        public init(id: Product.Id, isVerified: Bool) {
            self.id = id
            self.isVerified = isVerified
        }

        public let id: Product.Id
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

    enum FeedType: String, Hashable, Identifiable, Codable, Sendable {
        public var id: String { rawValue }

        case topRated, trending, latest
    }

    struct EditSuggestionRequest: Codable, Sendable {
        public let id: Product.Id?
        public let name: String?
        public let description: String?
        public let subBrandId: SubBrand.Id?
        public let categoryId: Category.Id?
        public let isDiscontinued: Bool?

        public init(
            id: Product.Id?,
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
            id: Product.Id? = nil,
            name: String? = nil,
            description: String? = nil,
            subBrandId: SubBrand.Id? = nil,
            categoryId: Category.Id? = nil,
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
}
