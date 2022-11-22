
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

extension SubBrand {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = "sub_brands"
        let saved = "id, name"
                
        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        case let .joined(withTableName):
            return queryWithTableName(tableName, joinWithComma(saved, Product.getQuery(.joinedBrandSubcategories(true))), withTableName)
        case let .joinedBrand(withTableName):
            return queryWithTableName(tableName, joinWithComma(saved, Brand.getQuery(.joinedCompany(true))), withTableName)
        }
    }
    
    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
        case joined(_ withTableName: Bool)
        case joinedBrand(_ withTableName: Bool)
    }
}

extension SubBrand {
    struct JoinedBrand: Identifiable, Hashable, Decodable {
        let id: Int
        let name: String?
        let brand: Brand.JoinedCompany
        
        func getSubBrand() -> SubBrand {
            return SubBrand(id: id, name: name)
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: JoinedBrand, rhs: JoinedBrand) -> Bool {
            return lhs.id == rhs.id
        }
        
        init(id: Int, name: String?, brand: Brand.JoinedCompany) {
            self.id = id
            self.name = name
            self.brand = brand
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case brand = "brands"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(Int.self, forKey: .id)
            name = try values.decodeIfPresent(String.self, forKey: .name)
            brand = try values.decode(Brand.JoinedCompany.self, forKey: .brand)
        }
    }
    
    struct JoinedProduct: Identifiable, Hashable, Decodable {
        let id: Int
        let name: String?
        let products: [Product.JoinedCategory]
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case products
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(Int.self, forKey: .id)
            name = try values.decodeIfPresent(String.self, forKey: .name)
            products = try values.decode([Product.JoinedCategory].self, forKey: .products)
        }
    }
}

extension SubBrand {
    struct NewRequest: Encodable {
        let name: String
        let brand_id: Int
        
        init(name: String, brandId: Int) {
            self.name = name
            self.brand_id = brandId
        }
    }

}
