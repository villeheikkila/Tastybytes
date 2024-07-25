public import Tagged

public extension Country {
    struct Saved: Hashable, Codable, Sendable {
        public let countryCode: Country.Id
        public let name: String
        public let emoji: String

        enum CodingKeys: String, CodingKey {
            case countryCode = "country_code"
            case name
            case emoji
        }
    }
}
