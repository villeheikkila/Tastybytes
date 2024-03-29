import Foundation

public struct Report: Decodable, Identifiable, Sendable, Hashable {
    public let id: Int
    public let message: String?
    public let createdAt: Date
    public let createdBy: Profile
    public let entity: Entity?
    public let resolvedAt: Date?

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        createdAt = try values.decode(Date.self, forKey: .createdAt)
        createdBy = try values.decode(Profile.self, forKey: .createdBy)
        resolvedAt = try values.decodeIfPresent(Date.self, forKey: .createdAt)

        let product = try values.decodeIfPresent(Product.Joined.self, forKey: .products)
        let company = try values.decodeIfPresent(Company.self, forKey: .companies)
        let brand = try values.decodeIfPresent(Brand.JoinedSubBrandsProductsCompany.self, forKey: .brands)
        let subBrand = try values.decodeIfPresent(SubBrand.JoinedBrand.self, forKey: .subBrands)
        let checkInComment = try values.decodeIfPresent(CheckInComment.Joined.self, forKey: .checkInComments)
        let checkIn = try values.decodeIfPresent(CheckIn.self, forKey: .checkIn)
        let checkInImageEntity = try values.decodeIfPresent(ImageEntity.JoinedCheckIn.self, forKey: .checkIn)
        let profile = try values.decodeIfPresent(Profile.self, forKey: .checkIn)

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
        } else if let checkInImageEntity {
            .checkInImage(checkInImageEntity)
        } else if let profile {
            .profile(profile)
        } else {
            nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case message
        case createdAt = "created_at"
        case createdBy = "created_by"
        case products
        case companies
        case checkInComments = "check_in_comments"
        case brands
        case checkInImages = "check_in_images"
        case checkIn = "check_in"
        case profile = "profiles"
        case subBrands = "sub_brands"
        case resolvedAt = "resolved_at"
    }

    public enum Entity: Hashable, Sendable {
        case product(Product.Joined)
        case company(Company)
        case brand(Brand.JoinedSubBrandsProductsCompany)
        case subBrand(SubBrand.JoinedBrand)
        case checkIn(CheckIn)
        case comment(CheckInComment.Joined)
        case checkInImage(ImageEntity.JoinedCheckIn)
        case profile(Profile)
    }
}

public extension Report {
    struct NewRequest: Codable, Sendable {
        public let message: String
        public let checkInId: Int?
        public let productId: Int?
        public let companyId: Int?
        public let checkInCommentId: Int?
        public let brandId: Int?
        public let subBrandId: Int?
        public let checkInImageId: Int?
        public let profileId: UUID?

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
                checkInImageId = nil
                profileId = nil
            case let .company(company):
                companyId = company.id
                checkInId = nil
                productId = nil
                checkInCommentId = nil
                brandId = nil
                subBrandId = nil
                checkInImageId = nil
                profileId = nil
            case let .brand(brand):
                brandId = brand.id
                checkInId = nil
                productId = nil
                companyId = nil
                checkInCommentId = nil
                subBrandId = nil
                checkInImageId = nil
                profileId = nil
            case let .subBrand(subBrand):
                subBrandId = subBrand.id
                checkInId = nil
                productId = nil
                companyId = nil
                checkInCommentId = nil
                brandId = nil
                checkInImageId = nil
                profileId = nil
            case let .comment(comment):
                checkInCommentId = comment.id
                checkInId = nil
                productId = nil
                companyId = nil
                brandId = nil
                subBrandId = nil
                checkInImageId = nil
                profileId = nil
            case let .checkIn(checkIn):
                checkInId = checkIn.id
                productId = nil
                companyId = nil
                checkInCommentId = nil
                brandId = nil
                subBrandId = nil
                checkInImageId = nil
                profileId = nil
            case let .checkInImage(imageEntity):
                checkInId = nil
                productId = nil
                companyId = nil
                checkInCommentId = nil
                brandId = nil
                subBrandId = nil
                checkInImageId = imageEntity.id
                profileId = nil
            case let .profile(profile):
                checkInId = nil
                productId = nil
                companyId = nil
                checkInCommentId = nil
                brandId = nil
                subBrandId = nil
                checkInImageId = nil
                profileId = profile.id
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
            case checkInImageId = "check_in_image_id"
            case profileId = "profile_id"
        }
    }

    struct ResolveRequest: Codable, Sendable {
        let resolvedAt: Date

        public init(resolvedAt: Date) {
            self.resolvedAt = resolvedAt
        }

        enum CodingKeys: String, CodingKey {
            case resolvedAt = "resolved_at"
        }
    }
}
