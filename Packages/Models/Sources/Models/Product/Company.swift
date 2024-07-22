import Foundation
import Tagged

public protocol CompanyLogoProtocol {
    var logos: [ImageEntity] { get }
}

public protocol CompanyProtocol: Hashable, Sendable, CompanyLogoProtocol, Verifiable {
    var id: Company.Id { get }
    var name: String { get }
    var isVerified: Bool { get }
    var logos: [ImageEntity] { get }
}

public struct Company: Identifiable, Codable, Hashable, Sendable, CompanyProtocol, CompanyLogoProtocol {
    public let id: Company.Id
    public let name: String
    public let isVerified: Bool
    public let logos: [ImageEntity]

    public init(id: Company.Id, name: String, logos: [ImageEntity] = [], isVerified: Bool) {
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

    public init(company: Company.Detailed) {
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
    typealias Id = Tagged<Company, Int>
}

public extension Company {
    struct Detailed: Identifiable, Decodable, Hashable, Sendable, CompanyLogoProtocol, CompanyProtocol, ModificationInfo {
        public let id: Company.Id
        public let name: String
        public let isVerified: Bool
        public let logos: [ImageEntity]
        public let editSuggestions: [EditSuggestion]
        public let subsidiaries: [Company]
        public let reports: [Report]
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
            case createdBy = "created_by"
            case createdAt = "created_at"
            case updatedBy = "updated_by"
            case updatedAt = "updated_at"
        }

        init(id: Company.Id, name: String, isVerified: Bool, logos: [ImageEntity], editSuggestions: [Company.EditSuggestion], subsidiaries: [Company], reports: [Report], createdBy: Profile? = nil, createdAt: Date, updatedBy: Profile? = nil, updatedAt: Date? = nil) {
            self.id = id
            self.name = name
            self.isVerified = isVerified
            self.logos = logos
            self.editSuggestions = editSuggestions
            self.subsidiaries = subsidiaries
            self.reports = reports
            self.createdBy = createdBy
            self.createdAt = createdAt
            self.updatedBy = updatedBy
            self.updatedAt = updatedAt
        }

        public init() {
            id = Company.Id(rawValue: 0)
            name = ""
            isVerified = false
            logos = []
            editSuggestions = []
            subsidiaries = []
            reports = []
            createdBy = nil
            createdAt = Date.now
            updatedBy = nil
            updatedAt = nil
        }

        public func copyWith(
            name: String? = nil,
            isVerified: Bool? = nil,
            logos: [ImageEntity]? = nil,
            editSuggestions: [EditSuggestion]? = nil,
            subsidiaries: [Company]? = nil,
            reports: [Report]? = nil
        ) -> Self {
            .init(
                id: id,
                name: name ?? self.name,
                isVerified: isVerified ?? self.isVerified,
                logos: logos ?? self.logos,
                editSuggestions: editSuggestions ?? self.editSuggestions,
                subsidiaries: subsidiaries ?? self.subsidiaries,
                reports: reports ?? self.reports,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedBy: updatedBy,
                updatedAt: updatedAt
            )
        }
    }

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

    struct Joined: Identifiable, Hashable, Codable, Sendable, CompanyProtocol, CompanyLogoProtocol {
        public let id: Company.Id
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

        public func copyWith(
            name: String? = nil,
            subsidiaries: [Company]? = nil,
            brands: [Brand.JoinedSubBrandsProducts]? = nil,
            logos: [ImageEntity]? = nil,
            isVerified: Bool? = nil
        ) -> Self {
            .init(
                id: id,
                name: name ?? self.name,
                subsidiaries: subsidiaries ?? self.subsidiaries,
                brands: brands ?? self.brands,
                logos: logos ?? self.logos,
                isVerified: isVerified ?? self.isVerified
            )
        }
    }
}

public extension Company.Joined {
    init(company: any CompanyProtocol) {
        id = company.id
        name = company.name
        isVerified = company.isVerified
        logos = company.logos
        subsidiaries = []
        brands = []
    }
}

public extension CompanyLogoProtocol {
    func getLogoUrl(baseUrl: URL) -> URL? {
        guard let logo = logos.first else { return nil }
        return logo.getLogoUrl(baseUrl: baseUrl)
    }
}

public extension Company {
    struct EditSuggestion: Identifiable, Codable, Hashable, Sendable, Resolvable, CreationInfo {
        public typealias Id = Tagged<Company.EditSuggestion, Int>

        public let id: Company.EditSuggestion.Id
        public let name: String?
        public let company: Company
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
