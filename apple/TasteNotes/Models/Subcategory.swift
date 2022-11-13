struct Subcategory: Identifiable, Decodable {
    let id: Int
    let name: String
}

extension Subcategory: Hashable {
    static func == (lhs: Subcategory, rhs: Subcategory) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Subcategory {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = "subcategories"
        let saved = "id, name"
        
        switch queryType {
        case let .joinedCategory(withTableName):
            return queryWithTableName(tableName, joinWithComma(saved, Category.getQuery(.saved(true))), withTableName)
        }
    }
    
    enum QueryType {
        case joinedCategory(_ withTableName: Bool)
    }
}

struct SubcategoryJoinedWithCategory: Identifiable {
    let id: Int
    let name: String
    let category: Category
    
    func getSubcategory() -> Subcategory {
        return Subcategory(id: id, name: name)
    }
}

extension SubcategoryJoinedWithCategory: Hashable {
    static func == (lhs: SubcategoryJoinedWithCategory, rhs: SubcategoryJoinedWithCategory) -> Bool {
        return lhs.id == rhs.id
    }
}

extension SubcategoryJoinedWithCategory: Decodable {
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

struct SubBrandNew: Encodable {
    let name: String
    let brand_id: Int
    
    init(name: String, brandId: Int) {
        self.name = name
        self.brand_id = brandId
    }
}
