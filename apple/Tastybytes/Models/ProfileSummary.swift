import Foundation

struct ProfileSummary: Decodable {
  let totalCheckIns: Int
  let uniqueCheckIns: Int
  let averageRating: Double?
  let unrated: Int
  let rating1: Int
  let rating2: Int
  let rating3: Int
  let rating4: Int
  let rating5: Int
  let rating6: Int
  let rating7: Int
  let rating8: Int
  let rating9: Int
  let rating10: Int

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

extension ProfileSummary {
  struct GetRequest: Encodable {
    let profileId: String

    enum CodingKeys: String, CodingKey {
      case profileId = "p_uid"
    }

    init(profileId: UUID) {
      self.profileId = profileId.uuidString
    }
  }
}
