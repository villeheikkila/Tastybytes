import Foundation

public protocol CompanyLogo {
    var logos: [ImageEntity] { get }
}

public struct Company: Identifiable, Codable, Hashable, Sendable, CompanyLogo {
    public let id: Int
    public let name: String
    public let isVerified: Bool
    public let logos: [ImageEntity]

    public init(id: Int, name: String, logos: [ImageEntity] = [], isVerified: Bool) {
        self.id = id
        self.name = name
        self.isVerified = isVerified
        self.logos = logos
    }

    public init(company: Company.Joined) {
        id = company.id
        name = company.name
        isVerified = company.isVerified
        logos = company.logos
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case logos = "company_logos"
        case isVerified = "is_verified"
    }

    public func copyWith(name: String? = nil, logos: [ImageEntity]? = nil, isVerified: Bool? = nil) -> Self {
        .init(
            id: id,
            name: name ?? self.name,
            logos: logos ?? self.logos,
            isVerified: isVerified ?? self.isVerified
        )
    }
}

public extension Company {
    struct NewRequest: Codable, Sendable {
        public init(name: String) {
            self.name = name
        }

        public let name: String
    }

    struct UpdateRequest: Codable, Sendable {
        public init(id: Int, name: String) {
            self.id = id
            self.name = name
        }

        public let id: Int
        public let name: String
    }

    struct EditSuggestionRequest: Codable, Sendable {
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

    struct VerifyRequest: Codable, Sendable {
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

    struct SummaryRequest: Codable, Sendable {
        public init(id: Int) {
            self.id = id
        }

        public let id: Int

        enum CodingKeys: String, CodingKey {
            case id = "p_company_id"
        }
    }

    struct Joined: Identifiable, Hashable, Codable, Sendable {
        public let id: Int
        public let name: String
        public let subsidiaries: [Company]
        public let brands: [Brand.JoinedSubBrandsProducts]
        public let logos: [ImageEntity]
        public let isVerified: Bool

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case isVerified = "is_verified"
            case subsidiaries = "companies"
            case brands
            case logos = "company_logos"
        }
    }
}

public extension CompanyLogo {
    func getLogoUrl(baseUrl: URL) -> URL? {
        guard let logo = logos.first else { return nil }
        return logo.getLogoUrl(baseUrl: baseUrl)
    }
}
