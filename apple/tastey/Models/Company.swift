import Foundation

struct Company: Identifiable {
    let id: Int
    let name: String
    let logoUrl: String?
    
    func getLogoUrl() -> URL? {
        if let logoUrl = logoUrl {
            let bucketId = "logos"
            let urlString = "\(Supabase.urlString)/storage/v1/object/public/\(bucketId)/\(logoUrl)"
            guard let url = URL(string: urlString) else { return nil }
            return url
        } else {
            return nil
        }
    }
    
}

extension Company: Hashable {
    static func == (lhs: Company, rhs: Company) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Company: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case logoUrl = "logo_url"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        logoUrl =  try values.decodeIfPresent(String.self, forKey: .logoUrl)
    }
}

struct NewCompany: Encodable {
    let name: String
}

struct CompanyJoined: Identifiable {
    let id: Int
    let name: String
    let logoUrl: String?
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
        case logoUrl
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        logoUrl =  try values.decodeIfPresent(String.self, forKey: .logoUrl)
        subsidiaries = try values.decode([Company].self, forKey: .subsidiaries)
        brands = try values.decode([BrandJoinedSubBrandsJoinedProduct].self, forKey: .brands)
    }
}

struct CompanySummary {
    let totalCheckIns: Int
    let averageRating: Double?
    let currentUserAverageRating: Double?
}

struct GetCompanySummaryParams: Encodable {
    let p_company_id: Int
    
    init(id: Int) {
        p_company_id = id
    }
}

extension CompanySummary: Decodable {
    enum CodingKeys: String, CodingKey {
        case totalCheckIns = "total_check_ins"
        case averageRating = "average_rating"
        case currentUserAverageRating = "current_user_average_rating"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        totalCheckIns = try values.decode(Int.self, forKey: .totalCheckIns)
        averageRating = try values.decodeIfPresent(Double.self, forKey: .averageRating)
        currentUserAverageRating = try values.decodeIfPresent(Double.self, forKey: .currentUserAverageRating)
    }
}
