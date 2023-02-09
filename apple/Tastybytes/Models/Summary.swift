import Foundation

struct Summary: Decodable, Hashable {
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

  func hash(into hasher: inout Hasher) {
    hasher.combine(totalCheckIns)
    hasher.combine(averageRating)
    hasher.combine(friendsTotalCheckIns)
    hasher.combine(friendsAverageRating)
    hasher.combine(currentUserTotalCheckIns)
    hasher.combine(currentUserAverageRating)
  }
}
