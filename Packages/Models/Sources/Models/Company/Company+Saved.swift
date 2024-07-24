public import Tagged

public extension Company {
    struct Saved: Identifiable, Codable, Hashable, Sendable, CompanyProtocol, CompanyLogoProtocol {
        public let id: Company.Id
        public let name: String
        public let isVerified: Bool
        public let logos: [ImageEntity.Saved]

        public init(id: Company.Id, name: String, logos: [ImageEntity.Saved] = [], isVerified: Bool) {
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

        public init() {
            id = .init(rawValue: 0)
            name = ""
            isVerified = false
            logos = []
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case logos = "company_logos"
            case isVerified = "is_verified"
        }

        public func copyWith(name: String? = nil, logos: [ImageEntity.Saved]? = nil, isVerified: Bool? = nil) -> Self {
            .init(
                id: id,
                name: name ?? self.name,
                logos: logos ?? self.logos,
                isVerified: isVerified ?? self.isVerified
            )
        }
    }
}
