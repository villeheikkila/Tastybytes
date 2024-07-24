import Foundation
public import Tagged

public enum AdminEventError: Error {
    case unknownEntity
}

public extension AdminEvent {
    struct Joined: Identifiable, Sendable, Decodable, Hashable {
        public let id: AdminEvent.Id
        public let reviewedAt: Date?
        public let reviewedBy: Profile?
        public let createdAt: Date
        public let content: Content

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

            id = try container.decode(AdminEvent.Id.self, forKey: .id)
            createdAt = try container.decode(Date.self, forKey: .createdAt)
            reviewedAt = try container.decodeIfPresent(Date.self, forKey: .reviewedAt)
            reviewedBy = try container.decodeIfPresent(Profile.self, forKey: .reviewedBy)

            let company = try container.decodeIfPresent(Company.Saved.self, forKey: .company)
            let product = try container.decodeIfPresent(Product.Joined.self, forKey: .product)
            let subBrand = try container.decodeIfPresent(SubBrand.JoinedBrand.self, forKey: .subBrand)
            let brand = try container.decodeIfPresent(Brand.self, forKey: .brand)
            let profile = try container.decodeIfPresent(Profile.self, forKey: .profile)
            let productEditSuggestion = try container.decodeIfPresent(Product.EditSuggestion.self, forKey: .productEditSuggestion)
            let brandEditSuggestion = try container.decodeIfPresent(Brand.EditSuggestion.self, forKey: .brandEditSuggestion)
            let subBrandEditSuggestion = try container.decodeIfPresent(SubBrand.EditSuggestion.self, forKey: .subBrandEditSuggestion)
            let companyEditSuggestion = try container.decodeIfPresent(Company.EditSuggestion.self, forKey: .companyEditSuggestion)
            let report = try container.decodeIfPresent(Report.Joined.self, forKey: .report)

            content = if let company {
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
                .editSuggestion(.product(productEditSuggestion))
            } else if let brandEditSuggestion {
                .editSuggestion(.brand(brandEditSuggestion))
            } else if let subBrandEditSuggestion {
                .editSuggestion(.subBrand(subBrandEditSuggestion))
            } else if let companyEditSuggestion {
                .editSuggestion(.company(companyEditSuggestion))
            } else if let report {
                .report(report)
            } else {
                throw AdminEventError.unknownEntity
            }
        }
    }
}

public extension AdminEvent {
    enum Content: Sendable, Hashable {
        case company(Company.Saved)
        case product(Product.Joined)
        case subBrand(SubBrand.JoinedBrand)
        case brand(Brand)
        case profile(Profile)
        case editSuggestion(EditSuggestion)
        case report(Report.Joined)
    }
}
