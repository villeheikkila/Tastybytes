import Foundation
public import Tagged

public extension Brand {
    struct EditSuggestion: Codable, Sendable, Identifiable, Hashable, Resolvable, CreationInfoCascade {
        public typealias Id = Tagged<Brand.EditSuggestion, Int>

        public let id: Brand.EditSuggestion.Id
        public let brand: Brand.Saved
        public let name: String?
        public let brandOwner: Company.Saved?
        public let createdBy: Profile.Saved
        public let createdAt: Date
        public let resolvedAt: Date?

        enum CodingKeys: String, CodingKey {
            case id, brand = "brands", name, brandOwner = "companies", createdBy = "profiles", createdAt = "created_at", resolvedAt = "resolved_at"
        }

        public func copyWith(resolvedAt: Date?) -> Self {
            .init(id: id, brand: brand, name: name, brandOwner: brandOwner, createdBy: createdBy, createdAt: createdAt, resolvedAt: resolvedAt)
        }
    }

    struct EditSuggestionRequest: Encodable, Sendable {
        let brandId: Brand.Id
        let name: String?
        let brandOwnerId: Company.Id?

        public init(brand: Brand.JoinedSubBrandsProductsCompany, name: String?, brandOwner: Company.Saved?) {
            brandId = brand.id
            self.name = name
            brandOwnerId = brandOwner?.id
        }

        enum CodingKeys: String, CodingKey {
            case name, brandId = "brand_id", brandOwnerId = "brand_owner_id"
        }

        typealias Id = Tagged<Brand.EditSuggestion, Int>
    }
}
