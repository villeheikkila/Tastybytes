import Foundation
public import Tagged

public enum ReportError: Error {
    case unknownEntity
}

public extension Report {
    struct Joined: Decodable, Identifiable, Sendable, Hashable {
        public let id: Report.Id
        public let message: String?
        public let createdAt: Date
        public let createdBy: Profile.Saved
        public let content: Content
        public let resolvedAt: Date?

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(Report.Id.self, forKey: .id)
            message = try values.decodeIfPresent(String.self, forKey: .message)
            createdAt = try values.decode(Date.self, forKey: .createdAt)
            createdBy = try values.decode(Profile.Saved.self, forKey: .createdBy)
            resolvedAt = try values.decodeIfPresent(Date.self, forKey: .createdAt)

            let product = try values.decodeIfPresent(Product.Joined.self, forKey: .product)
            let company = try values.decodeIfPresent(Company.Saved.self, forKey: .company)
            let brand = try values.decodeIfPresent(Brand.JoinedSubBrandsProductsCompany.self, forKey: .brand)
            let subBrand = try values.decodeIfPresent(SubBrand.JoinedBrand.self, forKey: .subBrand)
            let checkInComment = try values.decodeIfPresent(CheckIn.Comment.Joined.self, forKey: .checkInComment)
            let checkIn = try values.decodeIfPresent(CheckIn.Joined.self, forKey: .checkIn)
            let checkInImageEntity = try values.decodeIfPresent(ImageEntity.JoinedCheckIn.self, forKey: .checkInImage)
            let profile = try values.decodeIfPresent(Profile.Saved.self, forKey: .profile)
            let location = try values.decodeIfPresent(Location.Saved.self, forKey: .location)

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
    }
}
