struct Product: Hashable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let subBrand: SubBrand
    let subcategories: [Subcategory]

    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Product: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case subBrand = "sub_brands"
        case subcategories
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        description = try values.decode(String.self, forKey: .description)
        subBrand = try values.decode(SubBrand.self, forKey: .subBrand)
        subcategories = try values.decode([Subcategory].self, forKey: .subcategories)
    }
}
