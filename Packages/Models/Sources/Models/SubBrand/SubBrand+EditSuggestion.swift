import Foundation
public import Tagged

public extension SubBrand {
    struct EditSuggestion: Identifiable, Codable, Hashable, Sendable, Resolvable, CreationInfo {
        public typealias Id = Tagged<SubBrand.EditSuggestion, Int>

        public let id: SubBrand.EditSuggestion.Id
        public let subBrand: SubBrand.JoinedBrand
        public let createdAt: Date
        public let createdBy: Profile
        public let brand: Brand?
        public let name: String?
        public let includesBrandName: Bool?
        public let resolvedAt: Date?

        enum CodingKeys: String, CodingKey, Sendable {
            case id
            case name
            case createdAt = "created_at"
            case createdBy = "profiles"
            case brand = "brands"
            case subBrand = "sub_brands"
            case includesBrandName = "includes_brand_name"
            case resolvedAt = "resolved_at"
        }
    }
}
