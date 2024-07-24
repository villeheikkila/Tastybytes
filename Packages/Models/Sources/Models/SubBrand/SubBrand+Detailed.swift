import Foundation
public import Tagged

public extension SubBrand {
    struct Detailed: Identifiable, Hashable, Decodable, Sendable, SubBrandProtocol, ModificationInfo {
        public let id: SubBrand.Id
        public let name: String?
        public let includesBrandName: Bool
        public let isVerified: Bool
        public let products: [Product.JoinedCategory]
        public let brand: Brand.JoinedCompany
        public let editSuggestions: [SubBrand.EditSuggestion]
        public let reports: [Report.Joined]
        public let createdAt: Date
        public let createdBy: Profile?
        public let updatedAt: Date?
        public let updatedBy: Profile?

        init(
            id: SubBrand.Id,
            name: String? = nil,
            includesBrandName: Bool,
            isVerified: Bool,
            products: [Product.JoinedCategory],
            brand: Brand.JoinedCompany,
            editSuggestions: [SubBrand.EditSuggestion],
            reports: [Report.Joined],
            createdAt: Date,
            createdBy: Profile? = nil,
            updatedAt: Date? = nil,
            updatedBy: Profile? = nil
        ) {
            self.id = id
            self.name = name
            self.includesBrandName = includesBrandName
            self.isVerified = isVerified
            self.products = products
            self.brand = brand
            self.editSuggestions = editSuggestions
            self.reports = reports
            self.createdAt = createdAt
            self.createdBy = createdBy
            self.updatedAt = updatedAt
            self.updatedBy = updatedBy
        }

        public init() {
            id = .init(rawValue: 0)
            name = ""
            includesBrandName = false
            isVerified = false
            products = []
            brand = .init()
            editSuggestions = []
            reports = []
            createdAt = Date.now
            createdBy = nil
            updatedAt = nil
            updatedBy = nil
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case includesBrandName = "includes_brand_name"
            case products
            case brand = "brands"
            case editSuggestions = "sub_brand_edit_suggestions"
            case reports
            case createdBy = "created_by"
            case createdAt = "created_at"
            case updatedBy = "updated_by"
            case updatedAt = "updated_at"
        }

        public func copyWith(name: String? = nil, includesBrandName: Bool? = nil, isVerified: Bool? = nil, products: [Product.JoinedCategory]? = nil, brand: Brand.JoinedCompany? = nil, editSuggestions: [SubBrand.EditSuggestion]? = nil, reports: [Report.Joined]? = nil) -> Self {
            .init(
                id: id,
                name: name ?? self.name,
                includesBrandName: includesBrandName ?? self.includesBrandName,
                isVerified: isVerified ?? self.isVerified,
                products: products ?? self.products,
                brand: brand ?? self.brand,
                editSuggestions: editSuggestions ?? self.editSuggestions,
                reports: reports ?? self.reports,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy
            )
        }
    }
}
