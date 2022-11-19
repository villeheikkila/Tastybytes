import Foundation

struct ProductVariant: Identifiable {
    let id: Int
    let manufacturer: Company
}

extension ProductVariant {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = "product_variants"
        let saved = "id"
        
        switch queryType {
        case let .joined(withTableName):
            return queryWithTableName(tableName, joinWithComma(saved, Company.getQuery(.saved(true))), withTableName)
        }
    }
    
    enum QueryType {
        case joined(_ withTableName: Bool)
    }
}

extension ProductVariant: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ProductVariant, rhs: ProductVariant) -> Bool {
        return lhs.id == rhs.id
    }
}

extension ProductVariant: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case manufacturer = "companies"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        manufacturer = try values.decode(Company.self, forKey: .manufacturer)
    }
}
