public struct Report: Codable, Identifiable {
    public let id: Int
    public let message: String

    public struct NewRequest: Codable, Sendable {
        public let message: String
        public let checkInId: Int?
        public let productId: Int?
        public let companyId: Int?
        public let checkInCommentId: Int?
        public let brandId: Int?
        public let subBrandId: Int?

        public init(message: String, entity: Entity) {
            self.message = message

            switch entity {
            case let .product(product):
                productId = product.id
                checkInId = nil
                companyId = nil
                checkInCommentId = nil
                brandId = nil
                subBrandId = nil
            case let .company(company):
                companyId = company.id
                checkInId = nil
                productId = nil
                checkInCommentId = nil
                brandId = nil
                subBrandId = nil
            case let .brand(brand):
                brandId = brand.id
                checkInId = nil
                productId = nil
                companyId = nil
                checkInCommentId = nil
                subBrandId = nil
            case let .subBrand(_, subBrand):
                subBrandId = subBrand.id
                checkInId = nil
                productId = nil
                companyId = nil
                checkInCommentId = nil
                brandId = nil
            case let .comment(comment):
                checkInCommentId = comment.id
                checkInId = nil
                productId = nil
                companyId = nil
                brandId = nil
                subBrandId = nil
            case let .checkIn(checkIn):
                checkInId = checkIn.id
                productId = nil
                companyId = nil
                checkInCommentId = nil
                brandId = nil
                subBrandId = nil
            }
        }

        enum CodingKeys: String, CodingKey {
            case message
            case checkInId = "check_in_id"
            case productId = "product_id"
            case companyId = "company_id"
            case checkInCommentId = "check_in_comment_id"
            case brandId = "brand_id"
            case subBrandId = "sub_brand_id"
        }
    }

    public enum Entity: Hashable, Sendable {
        case product(Product.Joined)
        case company(Company)
        case brand(Brand.JoinedSubBrandsProductsCompany)
        case subBrand(Brand.JoinedSubBrandsProductsCompany, SubBrand.JoinedProduct)
        case checkIn(CheckIn)
        case comment(CheckInComment)

        public var label: String {
            switch self {
            case .product:
                "product"
            case .company:
                "company"
            case .brand:
                "brand"
            case .subBrand:
                "sub-brand"
            case .checkIn:
                "check-in"
            case .comment:
                "comment"
            }
        }
    }
}
