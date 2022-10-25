
struct SubBrand: Identifiable, Hashable, Decodable {
    let id: Int
    let name: String?
    
    init(id: Int, name: String?) {
        self.id = id
        self.name = name
    }
    
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
    
    func getSubBrand() -> SubBrand {
        return SubBrand(id: id, name: name)
    }
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

struct SubBrandJoinedProduct: Identifiable, Hashable, Decodable {
    let id: Int
    let name: String?
    let products: [ProductJoinedCategory]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case products
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        products = try values.decode([ProductJoinedCategory].self, forKey: .products)
    }
}

