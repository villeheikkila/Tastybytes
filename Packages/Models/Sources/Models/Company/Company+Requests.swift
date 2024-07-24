import Foundation

public extension Company {
    struct NewRequest: Codable, Sendable {
        public init(name: String) {
            self.name = name
        }

        public let name: String
    }

    struct UpdateRequest: Codable, Sendable {
        public init(id: Company.Id, name: String) {
            self.id = id
            self.name = name
        }

        public let id: Company.Id
        public let name: String
    }

    struct EditSuggestionRequest: Codable, Sendable {
        public init(id: Company.Id, name: String) {
            self.id = id
            self.name = name
        }

        public let id: Company.Id
        public let name: String

        enum CodingKeys: String, CodingKey {
            case id = "company_id"
            case name
        }
    }

    struct VerifyRequest: Codable, Sendable {
        public init(id: Company.Id, isVerified: Bool) {
            self.id = id
            self.isVerified = isVerified
        }

        public let id: Company.Id
        public let isVerified: Bool

        enum CodingKeys: String, CodingKey {
            case id = "p_company_id"
            case isVerified = "p_is_verified"
        }
    }

    struct SummaryRequest: Codable, Sendable {
        public init(id: Company.Id) {
            self.id = id
        }

        public let id: Company.Id

        enum CodingKeys: String, CodingKey {
            case id = "p_company_id"
        }
    }
}
