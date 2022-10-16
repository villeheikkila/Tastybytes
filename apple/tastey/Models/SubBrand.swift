
struct SubBrand: Identifiable, Hashable {
    let id: Int
    let name: String?
    let brand: Brand

    static func == (lhs: SubBrand, rhs: SubBrand) -> Bool {
        return lhs.id == rhs.id
    }
}

extension SubBrand: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case brand = "brands"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        brand = try values.decode(Brand.self, forKey: .brand)
    }
}
