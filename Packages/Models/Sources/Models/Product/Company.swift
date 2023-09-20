import Foundation

public protocol CompanyLogo {
    var logoFile: String? { get }
}

public struct Company: Identifiable, Codable, Hashable, Sendable, CompanyLogo {
    public init(id: Int, name: String, logoFile: String? = nil, isVerified: Bool) {
        self.id = id
        self.name = name
        self.logoFile = logoFile
        self.isVerified = isVerified
    }

    public let id: Int
    public let name: String
    public let logoFile: String?
    public let isVerified: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case logoFile = "logo_file"
        case isVerified = "is_verified"
    }
}

public extension Company {
    struct NewRequest: Codable {
        public init(name: String) {
            self.name = name
        }

        public let name: String
    }

    struct UpdateRequest: Codable {
        public init(id: Int, name: String) {
            self.id = id
            self.name = name
        }

        public let id: Int
        public let name: String
    }

    struct EditSuggestionRequest: Codable {
        public init(id: Int, name: String) {
            self.id = id
            self.name = name
        }

        public let id: Int
        public let name: String

        enum CodingKeys: String, CodingKey {
            case id = "company_id"
            case name
        }
    }

    struct VerifyRequest: Codable {
        public init(id: Int, isVerified: Bool) {
            self.id = id
            self.isVerified = isVerified
        }

        public let id: Int
        public let isVerified: Bool

        enum CodingKeys: String, CodingKey {
            case id = "p_company_id"
            case isVerified = "p_is_verified"
        }
    }

    struct SummaryRequest: Codable {
        public init(id: Int) {
            self.id = id
        }

        public let id: Int

        enum CodingKeys: String, CodingKey {
            case id = "p_company_id"
        }
    }

    struct Joined: Identifiable, Hashable, Codable {
        public let id: Int
        public let name: String
        public let logoUrl: String?
        public let subsidiaries: [Company]
        public let brands: [Brand.JoinedSubBrandsProducts]

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case subsidiaries = "companies"
            case brands
            case logoUrl
        }
    }
}

public extension CompanyLogo {
    var logoUrl: URL? {
        guard let logoFile else { return nil }
        return URL(bucket: .logos, fileName: logoFile)
    }
}
