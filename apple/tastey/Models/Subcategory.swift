struct Subcategory: Identifiable, Hashable {
    let id: Int
    let name: String
    let category: Category

    static func == (lhs: Subcategory, rhs: Subcategory) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Subcategory: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category = "categories"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        category = try values.decode(Category.self, forKey: .category)
    }
}
