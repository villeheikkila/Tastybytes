public struct Country: Hashable, Codable, Sendable {
    public let countryCode: String
    public let name: String
    public let emoji: String

    enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case name
        case emoji
    }
}
