struct Brand {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = "brands"
        let saved = "id, name"

        switch queryType {
        case .tableName:
            return tableName
        case let .joinedSubBrands(withTableName):
            return queryWithTableName(tableName, joinWithComma(saved, SubBrand.getQuery(.saved(true))), withTableName)
        case let .joined(withTableName):
            return queryWithTableName(tableName, joinWithComma(saved, SubBrand.getQuery(.joined(true))), withTableName)
        case let .joinedCompany(withTableName):
            return queryWithTableName(tableName, joinWithComma(saved, Company.getQuery(.saved(true))), withTableName)
        }
    }
    
    enum QueryType {
        case tableName
        case joined(_ withTableName: Bool)
        case joinedSubBrands(_ withTableName: Bool)
        case joinedCompany(_ withTableName: Bool)
    }
}

extension Brand {
    struct JoinedSubBrands: Identifiable, Hashable, Decodable {
        let id: Int
        let name: String
        let subBrands: [SubBrand]
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: JoinedSubBrands, rhs: JoinedSubBrands) -> Bool {
            return lhs.id == rhs.id
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case subBrands = "sub_brands"
        }
        
        init(id: Int, name: String, subBrands: [SubBrand]) {
            self.id = id
            self.name = name
            self.subBrands = subBrands
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(Int.self, forKey: .id)
            name = try values.decode(String.self, forKey: .name)
            subBrands = try values.decode([SubBrand].self, forKey: .subBrands)
        }
    }
    
    struct JoinedCompany: Identifiable, Hashable, Decodable {
        let id: Int
        let name: String
        let brandOwner: Company
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: JoinedCompany, rhs: JoinedCompany) -> Bool {
            return lhs.id == rhs.id
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case brandOwner = "companies"
        }
        
        init(id: Int, name: String, brandOwner: Company) {
            self.id = id
            self.name = name
            self.brandOwner = brandOwner
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(Int.self, forKey: .id)
            name = try values.decode(String.self, forKey: .name)
            brandOwner = try values.decode(Company.self, forKey: .brandOwner)
        }
    }
    
    struct JoinedSubBrandsProducts: Identifiable, Hashable, Decodable {
        let id: Int
        let name: String
        let subBrands: [SubBrand.JoinedProduct]
        
        func getNumberOfProducts() -> Int {
            return subBrands.flatMap { $0.products }.count
        }
        
        static func == (lhs: JoinedSubBrandsProducts, rhs: JoinedSubBrandsProducts) -> Bool {
            return lhs.id == rhs.id
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case subBrands = "sub_brands"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(Int.self, forKey: .id)
            name = try values.decode(String.self, forKey: .name)
            subBrands = try values.decode([SubBrand.JoinedProduct].self, forKey: .subBrands)
        }
    }
}



extension Brand {
    struct NewRequest: Encodable {
        let name: String
        let brand_owner_id: Int
        
        init(name: String, brandOwnerId: Int) {
            self.name = name
            self.brand_owner_id = brandOwnerId
        }
    }
}


