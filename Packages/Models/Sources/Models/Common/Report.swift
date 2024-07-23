import Foundation
import Tagged

public enum ReportError: Error {
    case unknownEntity
}

public struct Report: Decodable, Identifiable, Sendable, Hashable {
    public let id: Report.Id
    public let message: String?
    public let createdAt: Date
    public let createdBy: Profile
    public let content: Content
    public let resolvedAt: Date?

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Report.Id.self, forKey: .id)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        createdAt = try values.decode(Date.self, forKey: .createdAt)
        createdBy = try values.decode(Profile.self, forKey: .createdBy)
        resolvedAt = try values.decodeIfPresent(Date.self, forKey: .createdAt)

        let product = try values.decodeIfPresent(Product.Joined.self, forKey: .product)
        let company = try values.decodeIfPresent(Company.self, forKey: .company)
        let brand = try values.decodeIfPresent(Brand.JoinedSubBrandsProductsCompany.self, forKey: .brand)
        let subBrand = try values.decodeIfPresent(SubBrand.JoinedBrand.self, forKey: .subBrand)
        let checkInComment = try values.decodeIfPresent(CheckInComment.Joined.self, forKey: .checkInComment)
        let checkIn = try values.decodeIfPresent(CheckIn.self, forKey: .checkIn)
        let checkInImageEntity = try values.decodeIfPresent(ImageEntity.JoinedCheckIn.self, forKey: .checkInImage)
        let profile = try values.decodeIfPresent(Profile.self, forKey: .profile)
        let location = try values.decodeIfPresent(Location.self, forKey: .location)

        content = if let checkIn {
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
        } else if let location {
            .location(location)
        } else {
            throw ReportError.unknownEntity
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case message
        case createdAt = "created_at"
        case createdBy = "created_by"
        case product = "products"
        case company = "companies"
        case checkInComment = "check_in_comments"
        case brand = "brands"
        case checkIn = "check_ins"
        case subBrand = "sub_brands"
        case checkInImage = "check_in_images"
        case profile = "profiles"
        case location = "locations"
        case resolvedAt = "resolved_at"
    }

    public enum Content: Hashable, Sendable {
        case product(Product.Joined)
        case company(Company)
        case brand(Brand.JoinedSubBrandsProductsCompany)
        case subBrand(SubBrand.JoinedBrand)
        case checkIn(CheckIn)
        case comment(CheckInComment.Joined)
        case checkInImage(ImageEntity.JoinedCheckIn)
        case profile(Profile)
        case location(Location)
    }
}

public extension Report {
    typealias Id = Tagged<Report, Int>
}

public extension Report {
    struct NewRequest: Codable, Sendable {
        public let message: String
        public let checkInId: CheckIn.Id?
        public let productId: Product.Id?
        public let companyId: Company.Id?
        public let checkInCommentId: CheckInComment.Id?
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
