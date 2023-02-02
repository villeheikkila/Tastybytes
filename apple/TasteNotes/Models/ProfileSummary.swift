import Foundation

struct ProfileSummary {
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
}

extension ProfileSummary: Decodable {
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

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    totalCheckIns = try values.decode(Int.self, forKey: .totalCheckIns)
    uniqueCheckIns = try values.decode(Int.self, forKey: .uniqueCheckIns)
    averageRating = try values.decodeIfPresent(Double.self, forKey: .averageRating)
    unrated = try values.decode(Int.self, forKey: .unrated)
    rating1 = try values.decode(Int.self, forKey: .rating1)
    rating2 = try values.decode(Int.self, forKey: .rating2)
    rating3 = try values.decode(Int.self, forKey: .rating3)
    rating4 = try values.decode(Int.self, forKey: .rating4)
    rating5 = try values.decode(Int.self, forKey: .rating5)
    rating6 = try values.decode(Int.self, forKey: .rating6)
    rating7 = try values.decode(Int.self, forKey: .rating7)
    rating8 = try values.decode(Int.self, forKey: .rating8)
    rating9 = try values.decode(Int.self, forKey: .rating9)
    rating10 = try values.decode(Int.self, forKey: .rating10)
  }
}

extension ProfileSummary {
  struct GetRequest: Encodable {
    let p_uid: String

    init(profileId: UUID) {
      p_uid = profileId.uuidString
    }
  }
}
