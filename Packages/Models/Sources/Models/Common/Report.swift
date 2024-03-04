import Foundation

public struct Report: Decodable, Identifiable, Sendable {
    public let id: Int
    public let message: String?
    public let createdAt: Date
    public let createdBy: Profile
    public let entity: Entity?

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        createdAt = try values.decode(Date.self, forKey: .createdAt)
        createdBy = try values.decode(Profile.self, forKey: .createdBy)

        let product = try values.decodeIfPresent(Product.Joined.self, forKey: .products)
        let company = try values.decodeIfPresent(Company.self, forKey: .companies)
        let brand = try values.decodeIfPresent(Brand.JoinedSubBrandsProductsCompany.self, forKey: .brands)
        let subBrand = try values.decodeIfPresent(SubBrand.JoinedBrand.self, forKey: .subBrands)
        let checkInComment = try values.decodeIfPresent(CheckInComment.self, forKey: .checkInComments)
        let checkIn = try values.decodeIfPresent(CheckIn.self, forKey: .checkIn)

        entity = if let checkIn {
            .checkIn(checkIn)
        } else if let company {
            .company(company)
        } else if let checkInComment {
            .comment(checkInComment)
        } else if let brand {
            .brand(brand)
        } else if let product {
            .product(product)
        } else if let subBrand {
            .subBrand(subBrand)
        } else {
            nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case message
        case createdAt = "created_at"
        case createdBy = "profiles"
        case products
        case companies
        case checkInComments = "check_in_comments"
        case brands
        case checkIn = "check_in"
        case subBrands = "sub_brands"
    }

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
            case let .subBrand(subBrand):
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
        case subBrand(SubBrand.JoinedBrand)
        case checkIn(CheckIn)
        case comment(CheckInComment)
    }
}
