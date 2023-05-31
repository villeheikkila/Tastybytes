import Foundation

struct CheckInComment: Identifiable, Hashable, Codable, Sendable {
  let id: Int
  var content: String
  let createdAt: Date
  let profile: Profile

  enum CodingKeys: String, CodingKey {
    case id
    case content
    case createdAt = "created_at"
    case profile = "profiles"
  }
}

extension CheckInComment {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "check_in_comments"
    let saved = "id, content, created_at"

    switch queryType {
    case .tableName:
      return tableName
    case let .joinedProfile(withTableName):
      return queryWithTableName(tableName, [saved, Profile.getQuery(.minimal(true))].joinComma(), withTableName)
    case let .joinedCheckIn(withTableName):
      return queryWithTableName(
        tableName,
        [saved, Profile.getQuery(.minimal(true)), CheckIn.getQuery(.joined(true))].joinComma(),
        withTableName
      )
    }
  }

  enum QueryType {
    case tableName
    case joinedProfile(_ withTableName: Bool)
    case joinedCheckIn(_ withTableName: Bool)
  }
}

extension CheckInComment {
  struct Joined: Identifiable, Hashable, Codable, Sendable {
    let id: Int
    var content: String
    let createdAt: Date
    let profile: Profile
    let checkIn: CheckIn

    enum CodingKeys: String, CodingKey {
      case id
      case content
      case createdAt = "created_at"
      case profile = "profiles"
      case checkIn = "check_ins"
    }
  }

  struct NewRequest: Codable, Sendable {
    let content: String
    let checkInId: Int

    enum CodingKeys: String, CodingKey {
      case content, checkInId = "check_in_id"
    }
  }

  struct DeleteAsAdminRequest: Codable, Sendable {
    let id: Int

    init(comment: CheckInComment) {
      id = comment.id
    }

    enum CodingKeys: String, CodingKey {
      case id = "p_check_in_comment_id"
    }
  }

  struct UpdateRequest: Codable, Sendable {
    let id: Int
    let content: String
  }
}
