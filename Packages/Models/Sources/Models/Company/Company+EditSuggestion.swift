import Foundation
public import Tagged

public extension Company {
    struct EditSuggestion: Identifiable, Codable, Hashable, Sendable, Resolvable, CreationInfo {
        public typealias Id = Tagged<Company.EditSuggestion, Int>

        public let id: Company.EditSuggestion.Id
        public let name: String?
        public let company: Company.Saved
        public let createdBy: Profile
        public let createdAt: Date
        public let resolvedAt: Date?

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case company = "companies"
            case createdBy = "profiles"
            case createdAt = "created_at"
            case resolvedAt = "resolved_at"
        }

        public func copyWith(resolvedAt: Date?) -> Self {
            .init(id: id, name: name, company: company, createdBy: createdBy, createdAt: createdAt, resolvedAt: resolvedAt)
        }
    }
}
