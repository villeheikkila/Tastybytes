import Foundation

struct ProductVariant: Identifiable {
    let id: Int
    let manufacturer: Company
}

extension ProductVariant: Hashable {
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
