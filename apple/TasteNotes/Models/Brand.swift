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

struct BrandJoinedWithSubBrands: Identifiable {
    let id: Int
    let name: String
    let subBrands: [SubBrand]
}

extension BrandJoinedWithSubBrands: Hashable {
    static func == (lhs: BrandJoinedWithSubBrands, rhs: BrandJoinedWithSubBrands) -> Bool {
        return lhs.id == rhs.id
    }
}

extension BrandJoinedWithSubBrands: Decodable {
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

struct BrandJoinedWithCompany: Identifiable {
    let id: Int
    let name: String
    let brandOwner: Company
}

extension BrandJoinedWithCompany: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: BrandJoinedWithCompany, rhs: BrandJoinedWithCompany) -> Bool {
        return lhs.id == rhs.id
    }
}

extension BrandJoinedWithCompany: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case brandOwner = "companies"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        brandOwner = try values.decode(Company.self, forKey: .brandOwner)
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

struct BrandJoinedSubBrandsJoinedProduct: Identifiable {
    let id: Int
    let name: String
    let subBrands: [SubBrandJoinedProduct]
    
    func getNumberOfProducts() -> Int {
        return subBrands.flatMap { $0.products }.count
    }
}

extension BrandJoinedSubBrandsJoinedProduct: Hashable {
    static func == (lhs: BrandJoinedSubBrandsJoinedProduct, rhs: BrandJoinedSubBrandsJoinedProduct) -> Bool {
        return lhs.id == rhs.id
    }
}

extension BrandJoinedSubBrandsJoinedProduct: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case subBrands = "sub_brands"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        subBrands = try values.decode([SubBrandJoinedProduct].self, forKey: .subBrands)
    }
}
