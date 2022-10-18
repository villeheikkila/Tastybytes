struct Product: Identifiable {
    let id: Int
    let name: String
    let description: String
    let subBrand: SubBrandJoinedWithBrand
    let subcategories: [SubcategoryJoinedWithCategory]
    
    func getDisplayName(_ part: ProductNameParts) -> String {
        switch part {
        case .brandOwner:
            return subBrand.brand.company.name
        case .fullName:
            return [subBrand.brand.name, subBrand.name, name]
                .compactMap({ $0 })
                .joined(separator: " ")
        }
    }
}

extension Product {
    enum ProductNameParts {
        case brandOwner
        case fullName
    }
}

extension Product: Hashable {
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
        self.id = try values.decode(Int.self, forKey: .id)
        self.name = try values.decode(String.self, forKey: .name)
        self.description = try values.decode(String.self, forKey: .description)
        self.subBrand = try values.decode(SubBrandJoinedWithBrand.self, forKey: .subBrand)
        self.subcategories = try values.decode([SubcategoryJoinedWithCategory].self, forKey: .subcategories)
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
