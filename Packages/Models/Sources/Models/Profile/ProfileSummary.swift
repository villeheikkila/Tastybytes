import Charts
import Foundation

public struct ProfileSummary: Codable, Sendable {
    public let totalCheckIns: Int
    public let uniqueCheckIns: Int
    public let averageRating: Double?
    public let unrated: Int
    public let rating1: Int
    public let rating2: Int
    public let rating3: Int
    public let rating4: Int
    public let rating5: Int
    public let rating6: Int
    public let rating7: Int
    public let rating8: Int
    public let rating9: Int
    public let rating10: Int

    enum CodingKeys: String, CodingKey {
        case totalCheckIns = "total_check_ins"
        case uniqueCheckIns = "unique_check_ins"
        case averageRating = "average_rating"
        case unrated
        case rating1 = "rating_1"
        case rating2 = "rating_2"
        case rating3 = "rating_3"
        case rating4 = "rating_4"
        case rating5 = "rating_5"
        case rating6 = "rating_6"
        case rating7 = "rating_7"
        case rating8 = "rating_8"
        case rating9 = "rating_9"
        case rating10 = "rating_10"
    }
}

public extension ProfileSummary {
    struct GetRequest: Codable, Sendable {
        let profileId: String

        enum CodingKeys: String, CodingKey {
            case profileId = "p_uid"
        }

        public init(profileId: UUID) {
            self.profileId = profileId.uuidString
        }
    }
}
