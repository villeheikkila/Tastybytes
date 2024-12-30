import Foundation
public import Tagged

public extension Brand {
    struct Detailed: Identifiable, Hashable, Decodable, Sendable, BrandProtocol, ModificationInfo {
        public let id: Brand.Id
        public let name: String
        public let isVerified: Bool
        public let brandOwner: Company.Saved
        public let subBrands: [SubBrand.JoinedProduct]
        public let logos: [Logo.Saved]
        public let editSuggestions: [EditSuggestion]
        public let reports: [Report.Joined]
        public let createdBy: Profile.Saved?
        public let createdAt: Date
        public let updatedBy: Profile.Saved?
        public let updatedAt: Date?

        public var productCount: Int {
            subBrands.flatMap(\.products).count
        }

        init(
            id: Brand.Id,
            name: String,
            isVerified: Bool,
            brandOwner: Company.Saved,
            subBrands: [SubBrand.JoinedProduct],
            logos: [Logo.Saved],
            editSuggestions: [Brand.EditSuggestion],
            reports: [Report.Joined],
            createdBy: Profile.Saved? = nil,
            createdAt: Date,
            updatedBy: Profile.Saved? = nil,
            updatedAt: Date? = nil
        ) {
            self.id = id
            self.name = name
            self.isVerified = isVerified
            self.brandOwner = brandOwner
            self.subBrands = subBrands
            self.logos = logos
            self.editSuggestions = editSuggestions
            self.reports = reports
            self.createdBy = createdBy
            self.createdAt = createdAt
            self.updatedBy = updatedBy
            self.updatedAt = updatedAt
        }

        public init() {
            id = .init(rawValue: 0)
            name = ""
            isVerified = false
            brandOwner = .init()
            subBrands = []
            logos = []
            editSuggestions = []
            reports = []
            createdBy = nil
            createdAt = Date.now
            updatedBy = nil
            updatedAt = nil
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case brandOwner = "companies"
            case subBrands = "sub_brands"
            case logos
            case editSuggestions = "brand_edit_suggestions"
            case reports
            case createdBy = "created_by"
            case createdAt = "created_at"
            case updatedBy = "updated_by"
            case updatedAt = "updated_at"
        }

        public func copyWith(
            name: String? = nil,
            isVerified: Bool? = nil,
            brandOwner: Company.Saved? = nil,
            subBrands: [SubBrand.JoinedProduct]? = nil,
            logos: [Logo.Saved]? = nil,
            editSuggestions: [Brand.EditSuggestion]? = nil,
            reports: [Report.Joined]? = nil
        ) -> Self {
            .init(
                id: id,
                name: name ?? self.name,
                isVerified: isVerified ?? self.isVerified,
                brandOwner: brandOwner ?? self.brandOwner,
                subBrands: subBrands ?? self.subBrands,
                logos: logos ?? self.logos,
                editSuggestions: editSuggestions ?? self.editSuggestions,
                reports: reports ?? self.reports,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedBy: updatedBy,
                updatedAt: updatedAt
            )
        }
    }
}
