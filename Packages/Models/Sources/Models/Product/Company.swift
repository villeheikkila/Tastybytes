import Foundation

public protocol CompanyLogoProtocol {
    var logos: [ImageEntity] { get }
}

public protocol CompanyProtocol: Hashable, Codable, Sendable, CompanyLogoProtocol {
    var id: Int { get }
    var name: String { get }
    var isVerified: Bool { get }
    var logos: [ImageEntity] { get }
}

public struct Company: Identifiable, Codable, Hashable, Sendable, CompanyProtocol, CompanyLogoProtocol {
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

    public init(company: Company.Management) {
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
    struct Management: Identifiable, Codable, Hashable, Sendable, CompanyLogoProtocol, CompanyProtocol {
        public let id: Int
        public let name: String
        public let isVerified: Bool
        public let logos: [ImageEntity]
        public let createdBy: Profile?
        public let createdAt: Date?
        public let editSuggestions: [EditSuggestion]

        public init(company: Company) {
            id = company.id
            name = company.name
            isVerified = company.isVerified
            logos = company.logos
            createdBy = nil
            createdAt = nil
            editSuggestions = []
        }

        init(id: Int, name: String, isVerified: Bool, logos: [ImageEntity], createdBy: Profile? = nil, createdAt: Date? = nil, editSuggestions: [Company.EditSuggestion]) {
            self.id = id
            self.name = name
            self.isVerified = isVerified
            self.logos = logos
            self.createdBy = createdBy
            self.createdAt = createdAt
            self.editSuggestions = editSuggestions
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case logos = "company_logos"
            case isVerified = "is_verified"
            case createdBy = "profiles"
            case createdAt = "created_at"
            case editSuggestions = "company_edit_suggestions"
        }

        public func copyWith(
            id: Int? = nil,
            name: String? = nil,
            isVerified: Bool? = nil,
            logos: [ImageEntity]? = nil,
            createdBy: Profile?? = nil,
            createdAt: Date?? = nil,
            editSuggestions: [EditSuggestion]? = nil
        ) -> Self {
            .init(
                id: id ?? self.id,
                name: name ?? self.name,
                isVerified: isVerified ?? self.isVerified,
                logos: logos ?? self.logos,
                createdBy: createdBy ?? self.createdBy,
                createdAt: createdAt ?? self.createdAt,
                editSuggestions: editSuggestions ?? self.editSuggestions
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

    struct Joined: Identifiable, Hashable, Codable, Sendable, CompanyLogoProtocol {
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

        public var saved: Company {
            .init(id: id, name: name, logos: logos, isVerified: isVerified)
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
    struct EditSuggestion: Identifiable, Codable, Hashable, Sendable {
        public let id: Int
        public let name: String
        public let createdBy: Profile?
        public let createdAt: Date

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case createdBy = "profiles"
            case createdAt = "created_at"
        }
    }
}
