struct CheckInReaction: Identifiable, Decodable, Hashable, Sendable {
  let id: Int
  let profile: Profile

  init(id: Int, profile: Profile) {
    self.id = id
    self.profile = profile
  }

  enum CodingKeys: String, CodingKey {
    case id
    case content
    case profile = "profiles"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(Int.self, forKey: .id)
    profile = try values.decode(Profile.self, forKey: .profile)
  }
}

extension CheckInReaction {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "check_in_reactions"
    let saved = "id"

    switch queryType {
    case .tableName:
      return tableName
    case let .joinedProfileCheckIn(withTableName):
      return queryWithTableName(
        tableName,
        [saved, Profile.getQuery(.minimal(true)), CheckIn.getQuery(.joined(true))].joinComma(),
        withTableName
      )
    case let .joinedProfile(withTableName):
      return queryWithTableName(tableName, [saved, Profile.getQuery(.minimal(true))].joinComma(), withTableName)
    }
  }

  enum QueryType {
    case tableName
    case joinedProfile(_ withTableName: Bool)
    case joinedProfileCheckIn(_ withTableName: Bool)
  }
}

extension CheckInReaction {
  struct JoinedCheckIn: Identifiable, Hashable, Decodable, Sendable {
    let id: Int
    let profile: Profile
    let checkIn: CheckIn

    enum CodingKeys: String, CodingKey {
      case id
      case profile = "profiles"
      case checkIn = "check_ins"
    }
  }
}

extension CheckInReaction {
  struct NewRequest: Encodable, Sendable {
    let checkInId: Int

    enum CodingKeys: String, CodingKey {
      case checkInId = "p_check_in_id"
    }
  }

  struct DeleteRequest: Encodable, Sendable {
    let id: Int

    enum CodingKeys: String, CodingKey {
      case id = "p_check_in_reaction_id"
    }
  }
}
