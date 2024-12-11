public import Tagged

public extension Product {
    struct Joined: Identifiable, Hashable, Codable, Sendable, ProductProtocol {
        public let id: Product.Id
        public let name: String?
        public let description: String?
        public let isVerified: Bool
        public let subBrand: SubBrand.JoinedBrand
        public let category: Category.Saved
        public let subcategories: [Subcategory.Saved]
        public let barcodes: [Product.Barcode.Saved]?
        public let averageRating: Double?
        public let currentUserCheckIns: Int?
        public let isDiscontinued: Bool
        public let logos: [Logo.Saved]

        public var effectiveLogo: Logo.Saved? {
            logos.first ?? subBrand.brand.logos.first ?? subBrand.brand.brandOwner.logos.first
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
            case isDiscontinued = "is_discontinued"
            case logos
        }

        public var isCheckedInByCurrentUser: Bool {
            if let currentUserCheckIns, currentUserCheckIns > 0 {
                true
            } else {
                false
            }
        }

        public init(
            id: Product.Id,
            name: String?,
            description: String?,
            isVerified: Bool,
            subBrand: SubBrand.JoinedBrand,
            category: Category.Saved,
            subcategories: [Subcategory.Saved],
            barcodes: [Product.Barcode.Saved]?,
            isDiscontinued: Bool,
            logos: [Logo.Saved]
        ) {
            self.id = id
            self.name = name
            self.description = description
            self.isVerified = isVerified
            self.subBrand = subBrand
            self.subcategories = subcategories
            self.category = category
            self.barcodes = barcodes
            self.isDiscontinued = isDiscontinued
            self.logos = logos
            currentUserCheckIns = nil
            averageRating = nil
        }

        public init(
            company: Company.Saved,
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
                includesBrandName: subBrand.includesBrandName,
                isVerified: subBrand.isVerified,
                brand: Brand.JoinedCompany(
                    id: brand.id,
                    name: brand.name,
                    isVerified: brand.isVerified,
                    brandOwner: company,
                    logos: brand.logos
                )
            )
            subcategories = product.subcategories
            category = product.category
            barcodes = []
            logos = product.logos
            currentUserCheckIns = nil
            averageRating = nil
            isDiscontinued = product.isDiscontinued
        }

        public init(product: Product.JoinedCategory, subBrand: SubBrand.Detailed) {
            id = product.id
            name = product.name
            description = product.description
            isVerified = product.isVerified
            self.subBrand = .init(subBrand: subBrand)
            subcategories = product.subcategories
            category = product.category
            barcodes = []
            currentUserCheckIns = nil
            averageRating = nil
            isDiscontinued = product.isDiscontinued
            logos = product.logos
        }

        public init(
            product: Product.JoinedCategory,
            subBrand: SubBrand.JoinedProduct,
            brand: Brand.JoinedSubBrandsCompany
        ) {
            id = product.id
            name = product.name
            description = product.description
            isVerified = product.isVerified
            self.subBrand = SubBrand.JoinedBrand(
                id: subBrand.id,
                name: subBrand.name,
                includesBrandName: subBrand.includesBrandName,
                isVerified: subBrand.isVerified,
                brand: Brand.JoinedCompany(
                    id: brand.id,
                    name: brand.name,
                    isVerified: brand.isVerified,
                    brandOwner: brand.brandOwner,
                    logos: brand.logos
                )
            )
            subcategories = product.subcategories
            category = product.category
            barcodes = []
            currentUserCheckIns = nil
            averageRating = nil
            isDiscontinued = product.isDiscontinued
            logos = product.logos
        }

        public init(product: Product.Detailed) {
            id = product.id
            name = product.name
            description = product.description
            isVerified = product.isVerified
            subBrand = product.subBrand
            subcategories = product.subcategories
            category = product.category
            barcodes = product.barcodes.map { .init(barcode: $0) }
            isDiscontinued = product.isDiscontinued
            logos = product.logos
            currentUserCheckIns = nil
            averageRating = nil
        }

        public init() {
            id = .init(rawValue: 0)
            name = ""
            description = nil
            isVerified = false
            subBrand = .init()
            subcategories = []
            category = .init()
            barcodes = []
            isDiscontinued = false
            logos = []
            currentUserCheckIns = nil
            averageRating = nil
        }

        public func copyWith(
            name: String? = nil,
            description: String? = nil,
            isVerified: Bool? = nil,
            subBrand: SubBrand.JoinedBrand? = nil,
            category: Category.Saved? = nil,
            subcategories: [Subcategory.Saved]? = nil,
            barcodes: [Product.Barcode.Saved]? = nil,
            isDiscontinued: Bool? = nil,
            logos: [Logo.Saved]? = nil
        ) -> Self {
            .init(
                id: id,
                name: name ?? self.name,
                description: description ?? self.description,
                isVerified: isVerified ?? self.isVerified,
                subBrand: subBrand ?? self.subBrand,
                category: category ?? self.category,
                subcategories: subcategories ?? self.subcategories,
                barcodes: barcodes ?? self.barcodes,
                isDiscontinued: isDiscontinued ?? self.isDiscontinued,
                logos: logos ?? self.logos
            )
        }
    }
}
