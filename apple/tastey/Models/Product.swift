struct Product: Hashable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let subBrand: SubBrandJoinedWithBrand
    let subcategories: [SubcategoryJoinedWithCategory]

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
        subBrand = try values.decode(SubBrandJoinedWithBrand.self, forKey: .subBrand)
        subcategories = try values.decode([SubcategoryJoinedWithCategory].self, forKey: .subcategories)
    }
}

struct NewProductParams: Encodable {
    let p_name: String
    let p_description: String?
    let p_category_id: Int
    let p_sub_brand_id: Int
    let p_sub_category_ids: [Int]
    
    
    init(name: String, description: String?, categoryId: Int, subBrandId: Int, subCategoryIds: [Int]) {
        self.p_name = name
        self.p_description = description
        self.p_category_id = categoryId
        self.p_sub_brand_id = subBrandId
        self.p_sub_category_ids = subCategoryIds
        
    }
    
}
