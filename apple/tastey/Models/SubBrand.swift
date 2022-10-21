
struct SubBrand: Identifiable, Hashable, Decodable {
    let id: Int
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
    }
}

struct SubBrandJoinedWithBrand: Identifiable {
    let id: Int
    let name: String?
    let brand: BrandJoinedWithCompany
}

extension SubBrandJoinedWithBrand: Hashable {
    static func == (lhs: SubBrandJoinedWithBrand, rhs: SubBrandJoinedWithBrand) -> Bool {
        return lhs.id == rhs.id
    }
}

extension SubBrandJoinedWithBrand: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case brand = "brands"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        brand = try values.decode(BrandJoinedWithCompany.self, forKey: .brand)
    }
}
