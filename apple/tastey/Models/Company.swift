import Foundation

struct Company: Identifiable, Decodable {
    let id: Int
    let name: String
}

extension Company: Hashable {
    static func == (lhs: Company, rhs: Company) -> Bool {
        return lhs.id == rhs.id
    }
}

struct NewCompany: Encodable {
    let name: String
}

struct CompanyJoined: Identifiable {
    let id: Int
    let name: String
    let subsidiaries: [Company]
    let brands: [BrandJoinedSubBrandsJoinedProduct]
}

extension CompanyJoined: Hashable {
    static func == (lhs: CompanyJoined, rhs: CompanyJoined) -> Bool {
        return lhs.id == rhs.id
    }
}

extension CompanyJoined: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case subsidiaries = "companies"
        case brands
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        subsidiaries = try values.decode([Company].self, forKey: .subsidiaries)
        brands = try values.decode([BrandJoinedSubBrandsJoinedProduct].self, forKey: .brands)
    }
}
