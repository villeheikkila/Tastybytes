public extension SubBrand {
    struct NewRequest: Codable, Sendable {
        let name: String
        let brandId: Brand.Id
        let includesBrandName: Bool

        enum CodingKeys: String, CodingKey, Sendable {
            case name
            case brandId = "brand_id"
            case includesBrandName = "includes_brand_name"
        }

        public init(name: String, brandId: Brand.Id, includesBrandName: Bool) {
            self.name = name
            self.brandId = brandId
            self.includesBrandName = includesBrandName
        }
    }

    struct UpdateNameRequest: Codable, Sendable {
        public let id: SubBrand.Id
        public let name: String
        public let includesBrandName: Bool

        public init(id: SubBrand.Id, name: String, includesBrandName: Bool) {
            self.id = id
            self.name = name
            self.includesBrandName = includesBrandName
        }

        enum CodingKeys: String, CodingKey {
            case id, name, includesBrandName = "includes_brand_name"
        }
    }

    struct UpdateBrandRequest: Codable, Sendable {
        public let id: SubBrand.Id
        public let brandId: Brand.Id

        enum CodingKeys: String, CodingKey {
            case id, brandId = "brand_id"
        }

        public init(id: SubBrand.Id, brandId: Brand.Id) {
            self.id = id
            self.brandId = brandId
        }
    }

    struct VerifyRequest: Codable, Sendable {
        public init(id: SubBrand.Id, isVerified: Bool) {
            self.id = id
            self.isVerified = isVerified
        }

        public let id: SubBrand.Id
        public let isVerified: Bool

        enum CodingKeys: String, CodingKey {
            case id = "p_sub_brand_id"
            case isVerified = "p_is_verified"
        }
    }

    enum Update: Sendable {
        case brand(UpdateBrandRequest)
        case name(UpdateNameRequest)
    }
}
