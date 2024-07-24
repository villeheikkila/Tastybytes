import Foundation
public import Tagged

public extension Company {
    struct Detailed: Identifiable, Decodable, Hashable, Sendable, CompanyLogoProtocol, CompanyProtocol, ModificationInfo {
        public let id: Company.Id
        public let name: String
        public let isVerified: Bool
        public let logos: [ImageEntity.Saved]
        public let editSuggestions: [EditSuggestion]
        public let subsidiaries: [Company.Saved]
        public let reports: [Report.Joined]
        public let productVariants: [Product.Variant.JoinedProduct]
        public let createdBy: Profile?
        public let createdAt: Date
        public let updatedBy: Profile?
        public let updatedAt: Date?

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case logos = "company_logos"
            case isVerified = "is_verified"
            case editSuggestions = "company_edit_suggestions"
            case subsidiaries = "companies"
            case reports
            case productVariants = "product_variants"
            case createdBy = "created_by"
            case createdAt = "created_at"
            case updatedBy = "updated_by"
            case updatedAt = "updated_at"
        }

        init(
            id: Company.Id,
            name: String,
            isVerified: Bool,
            logos: [ImageEntity.Saved],
            editSuggestions: [Company.EditSuggestion],
            subsidiaries: [Company.Saved],
            reports: [Report.Joined],
            productVariants: [Product.Variant.JoinedProduct],
            createdBy: Profile? = nil,
            createdAt: Date,
            updatedBy: Profile? = nil,
            updatedAt: Date? = nil
        ) {
            self.id = id
            self.name = name
            self.isVerified = isVerified
            self.logos = logos
            self.editSuggestions = editSuggestions
            self.subsidiaries = subsidiaries
            self.reports = reports
            self.productVariants = productVariants
            self.createdBy = createdBy
            self.createdAt = createdAt
            self.updatedBy = updatedBy
            self.updatedAt = updatedAt
        }

        public init() {
            id = .init(rawValue: 0)
            name = ""
            isVerified = false
            logos = []
            editSuggestions = []
            subsidiaries = []
            reports = []
            productVariants = []
            createdBy = nil
            createdAt = Date.now
            updatedBy = nil
            updatedAt = nil
        }

        public func copyWith(
            name: String? = nil,
            isVerified: Bool? = nil,
            logos: [ImageEntity.Saved]? = nil,
            editSuggestions: [EditSuggestion]? = nil,
            subsidiaries: [Company.Saved]? = nil,
            reports: [Report.Joined]? = nil,
            productVariants: [Product.Variant.JoinedProduct]? = nil
        ) -> Self {
            .init(
                id: id,
                name: name ?? self.name,
                isVerified: isVerified ?? self.isVerified,
                logos: logos ?? self.logos,
                editSuggestions: editSuggestions ?? self.editSuggestions,
                subsidiaries: subsidiaries ?? self.subsidiaries,
                reports: reports ?? self.reports,
                productVariants: productVariants ?? self.productVariants,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedBy: updatedBy,
                updatedAt: updatedAt
            )
        }
    }
}
