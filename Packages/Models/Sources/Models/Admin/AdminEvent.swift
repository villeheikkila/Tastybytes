import Foundation

public enum AdminEventError: Error {
    case unknownEntity
}

public struct AdminEvent: Identifiable, Sendable, Decodable, Hashable {
    public enum Event: Sendable, Hashable {
        case company(Company)
        case product(Product.Joined)
        case subBrand(SubBrand.JoinedBrand)
        case brand(Brand)
        case profile(Profile)
        case productEditSuggestion(Product.EditSuggestion)
        case brandEditSuggestion(Brand.EditSuggestion)
        case subBrandEditSuggestion(SubBrand.EditSuggestion)
        case companyEditSuggestion(Company.EditSuggestion)
        case report(Report)
    }

    public let id: Int
    public let reviewedAt: Date?
    public let reviewedBy: Profile?
    public let createdAt: Date
    public let event: Event

    private enum CodingKeys: String, CodingKey {
        case id
        case reviewedAt = "reviewed_at"
        case reviewedBy = "reviewed_by"
        case createdAt = "created_at"
        case company = "companies"
        case product = "products"
        case profile = "profiles"
        case subBrand = "sub_brands"
        case brand = "brands"
        case productEditSuggestion = "product_edit_suggestions"
        case brandEditSuggestion = "brand_edit_suggestions"
        case subBrandEditSuggestion = "sub_brand_edit_suggestions"
        case companyEditSuggestion = "company_edit_suggestions"
        case report = "reports"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        reviewedAt = try container.decodeIfPresent(Date.self, forKey: .reviewedAt)
        reviewedBy = try container.decodeIfPresent(Profile.self, forKey: .reviewedBy)

        let company = try container.decodeIfPresent(Company.self, forKey: .company)
        let product = try container.decodeIfPresent(Product.Joined.self, forKey: .product)
        let subBrand = try container.decodeIfPresent(SubBrand.JoinedBrand.self, forKey: .subBrand)
        let brand = try container.decodeIfPresent(Brand.self, forKey: .brand)
        let profile = try container.decodeIfPresent(Profile.self, forKey: .profile)
        let productEditSuggestion = try container.decodeIfPresent(Product.EditSuggestion.self, forKey: .productEditSuggestion)
        let brandEditSuggestion = try container.decodeIfPresent(Brand.EditSuggestion.self, forKey: .brandEditSuggestion)
        let subBrandEditSuggestion = try container.decodeIfPresent(SubBrand.EditSuggestion.self, forKey: .subBrandEditSuggestion)
        let companyEditSuggestion = try container.decodeIfPresent(Company.EditSuggestion.self, forKey: .companyEditSuggestion)
        let report = try container.decodeIfPresent(Report.self, forKey: .report)

        event = if let company {
            .company(company)
        } else if let product {
            .product(product)
        } else if let subBrand {
            .subBrand(subBrand)
        } else if let brand {
            .brand(brand)
        } else if let profile {
            .profile(profile)
        } else if let productEditSuggestion {
            .productEditSuggestion(productEditSuggestion)
        } else if let brandEditSuggestion {
            .brandEditSuggestion(brandEditSuggestion)
        } else if let subBrandEditSuggestion {
            .subBrandEditSuggestion(subBrandEditSuggestion)
        } else if let companyEditSuggestion {
            .companyEditSuggestion(companyEditSuggestion)
        } else if let report {
            .report(report)
        } else {
            throw AdminEventError.unknownEntity
        }
    }
}
