
struct BrandJoinedWithSubBrands: Identifiable, Hashable, Decodable {
    let id: Int
    let name: String
    let subBrands: [SubBrand]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case subBrands = "sub_brands"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        subBrands = try values.decode([SubBrand].self, forKey: .subBrands)
    }
}

struct BrandJoinedWithCompany: Identifiable, Hashable {
    let id: Int
    let name: String
    let company: Company

    static func == (lhs: BrandJoinedWithCompany, rhs: BrandJoinedWithCompany) -> Bool {
        return lhs.id == rhs.id
    }
}

extension BrandJoinedWithCompany: Decodable {
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

struct NewBrand: Encodable {
    let name: String
    let brand_owner_id: Int
    
    init(name: String, brandOwnerId: Int) {
        self.name = name
        self.brand_owner_id = brandOwnerId
    }
}
