public import Tagged

public extension Company {
    struct Joined: Identifiable, Hashable, Codable, Sendable, CompanyProtocol, CompanyLogoProtocol {
        public let id: Company.Id
        public let name: String
        public let subsidiaries: [Company.Saved]
        public let brands: [Brand.JoinedSubBrandsProducts]
        public let logos: [ImageEntity.Saved]
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
            subsidiaries: [Company.Saved]? = nil,
            brands: [Brand.JoinedSubBrandsProducts]? = nil,
            logos: [ImageEntity.Saved]? = nil,
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

public extension Company.Joined {
    init() {
        id = .init(rawValue: 0)
        name = ""
        isVerified = false
        logos = []
        subsidiaries = []
        brands = []
    }
}
