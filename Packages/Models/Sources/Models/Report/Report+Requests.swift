import Foundation

public extension Report {
    struct NewRequest: Codable, Sendable {
        public let message: String
        public let checkInId: CheckIn.Id?
        public let productId: Product.Id?
        public let companyId: Company.Id?
        public let checkInCommentId: CheckIn.Comment.Id?
        public let brandId: Brand.Id?
        public let subBrandId: SubBrand.Id?
        public let checkInImageId: ImageEntity.Id?
        public let profileId: Profile.Id?
        public let locationId: Location.Id?

        public init(message: String, entity: Content) {
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
                locationId = nil
            case let .company(company):
                companyId = company.id
                checkInId = nil
                productId = nil
                checkInCommentId = nil
                brandId = nil
                subBrandId = nil
                checkInImageId = nil
                profileId = nil
                locationId = nil
            case let .brand(brand):
                brandId = brand.id
                checkInId = nil
                productId = nil
                companyId = nil
                checkInCommentId = nil
                subBrandId = nil
                checkInImageId = nil
                profileId = nil
                locationId = nil
            case let .subBrand(subBrand):
                subBrandId = subBrand.id
                checkInId = nil
                productId = nil
                companyId = nil
                checkInCommentId = nil
                brandId = nil
                checkInImageId = nil
                profileId = nil
                locationId = nil
            case let .comment(comment):
                checkInCommentId = comment.id
                checkInId = nil
                productId = nil
                companyId = nil
                brandId = nil
                subBrandId = nil
                checkInImageId = nil
                profileId = nil
                locationId = nil
            case let .checkIn(checkIn):
                checkInId = checkIn.id
                productId = nil
                companyId = nil
                checkInCommentId = nil
                brandId = nil
                subBrandId = nil
                checkInImageId = nil
                profileId = nil
                locationId = nil
            case let .checkInImage(imageEntity):
                checkInId = nil
                productId = nil
                companyId = nil
                checkInCommentId = nil
                brandId = nil
                subBrandId = nil
                checkInImageId = imageEntity.id
                profileId = nil
                locationId = nil
            case let .profile(profile):
                checkInId = nil
                productId = nil
                companyId = nil
                checkInCommentId = nil
                brandId = nil
                subBrandId = nil
                checkInImageId = nil
                profileId = profile.id
                locationId = nil
            case let .location(location):
                checkInId = nil
                productId = nil
                companyId = nil
                checkInCommentId = nil
                brandId = nil
                subBrandId = nil
                checkInImageId = nil
                profileId = nil
                locationId = location.id
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
            case locationId = "location_id"
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
