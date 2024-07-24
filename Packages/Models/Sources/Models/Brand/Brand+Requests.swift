public import Tagged

public extension Brand {
    struct NewRequest: Codable, Sendable {
        public let name: String
        public let brandOwnerId: Company.Id

        enum CodingKeys: String, CodingKey {
            case name, brandOwnerId = "brand_owner_id"
        }

        public init(name: String, brandOwnerId: Company.Id) {
            self.name = name
            self.brandOwnerId = brandOwnerId
        }
    }

    struct UpdateRequest: Codable, Sendable {
        public let id: Brand.Id
        public let name: String
        public let brandOwnerId: Company.Id?

        enum CodingKeys: String, CodingKey {
            case id, name, brandOwnerId = "brand_owner_id"
        }

        public init(id: Brand.Id, name: String, brandOwnerId: Company.Id?) {
            self.id = id
            self.name = name
            self.brandOwnerId = brandOwnerId
        }
    }

    struct VerifyRequest: Codable, Sendable {
        public let id: Brand.Id
        public let isVerified: Bool

        public init(id: Brand.Id, isVerified: Bool) {
            self.id = id
            self.isVerified = isVerified
        }

        enum CodingKeys: String, CodingKey {
            case id = "p_brand_id"
            case isVerified = "p_is_verified"
        }
    }
}
