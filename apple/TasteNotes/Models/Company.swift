import Foundation

struct Company: Identifiable {
    let id: Int
    let name: String
    let logoUrl: String?

    func getLogoUrl() -> URL? {
        if let logoUrl = logoUrl {
            let bucketId = "logos"
            let urlString = "\(Config.supabaseUrl.absoluteString)/storage/v1/object/public/\(bucketId)/\(logoUrl)"
            guard let url = URL(string: urlString) else { return nil }
            return url
        } else {
            return nil
        }
    }
}

extension Company {
    static func getQuery(_ queryType: QueryType) -> String {
        let tableName = "companies"
        let saved = "id, name, logo_url"
        let owner = queryWithTableName(tableName, saved, true)

        switch queryType {
        case .tableName:
            return tableName
        case let .saved(withTableName):
            return queryWithTableName(tableName, saved, withTableName)
        case let .joinedBrandSubcategoriesOwner(withTableName):
            return queryWithTableName(tableName, joinWithComma(saved, owner, Brand.getQuery(.joined(true))), withTableName)
        }
    }

    enum QueryType {
        case tableName
        case saved(_ withTableName: Bool)
        case joinedBrandSubcategoriesOwner(_ withTableName: Bool)
    }
}

extension Company: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(logoUrl)
    }

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
        logoUrl = try values.decodeIfPresent(String.self, forKey: .logoUrl)
    }
}

extension Company {
    struct NewRequest: Encodable {
        let name: String
    }

    struct SummaryRequest: Encodable {
        let p_company_id: Int

        init(id: Int) {
            p_company_id = id
        }
    }

    struct Summary: Decodable {
        let totalCheckIns: Int
        let averageRating: Double?
        let friendsTotalCheckIns: Int
        let friendsAverageRating: Double?
        let currentUserTotalCheckIns: Int
        let currentUserAverageRating: Double?

        enum CodingKeys: String, CodingKey {
            case totalCheckIns = "total_check_ins"
            case averageRating = "average_rating"
            case friendsTotalCheckIns = "friends_check_ins"
            case friendsAverageRating = "friends_average_rating"
            case currentUserTotalCheckIns = "current_user_check_ins"
            case currentUserAverageRating = "current_user_average_rating"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            totalCheckIns = try values.decode(Int.self, forKey: .totalCheckIns)
            averageRating = try values.decodeIfPresent(Double.self, forKey: .averageRating)
            friendsTotalCheckIns = try values.decode(Int.self, forKey: .friendsTotalCheckIns)
            friendsAverageRating = try values.decodeIfPresent(Double.self, forKey: .friendsAverageRating)
            currentUserTotalCheckIns = try values.decode(Int.self, forKey: .currentUserTotalCheckIns)
            currentUserAverageRating = try values.decodeIfPresent(Double.self, forKey: .currentUserAverageRating)
        }
    }

    struct Joined: Identifiable, Hashable, Decodable {
        let id: Int
        let name: String
        let logoUrl: String?
        let subsidiaries: [Company]
        let brands: [Brand.JoinedSubBrandsProducts]

        static func == (lhs: Joined, rhs: Joined) -> Bool {
            return lhs.id == rhs.id
        }

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
            logoUrl = try values.decodeIfPresent(String.self, forKey: .logoUrl)
            subsidiaries = try values.decode([Company].self, forKey: .subsidiaries)
            brands = try values.decode([Brand.JoinedSubBrandsProducts].self, forKey: .brands)
        }
    }
}
