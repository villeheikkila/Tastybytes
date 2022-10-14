
struct Brand: Identifiable, Hashable {
    let id: Int
    let name: String
    let company: Company

    static func == (lhs: Brand, rhs: Brand) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Brand: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case company = "companies"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        company = try values.decode(Company.self, forKey: .company)
    }
}
