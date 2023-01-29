import Foundation

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
