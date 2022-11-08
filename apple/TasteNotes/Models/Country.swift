struct Country: Identifiable, Hashable {
    var id: String { countryCode }
    let countryCode: String
    let name: String
    let emoji: String
}

extension Country: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case countryCode = "country_code"
        case name
        case emoji
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        countryCode = try container.decode(String.self, forKey: .countryCode)
        name = try container.decode(String.self, forKey: .name)
        emoji = try container.decode(String.self, forKey: .emoji)
    }
}
