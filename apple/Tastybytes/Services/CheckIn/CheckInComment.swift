import Foundation

struct CheckInComment: Identifiable, Hashable {
  let id: Int
  var content: String
  let createdAt: Date
  let profile: Profile
}

extension CheckInComment: Decodable {
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
      return queryWithTableName(tableName, joinWithComma(saved, Profile.getQuery(.minimal(true))), withTableName)
    }
  }

  enum QueryType {
    case tableName
    case joinedProfile(_ withTableName: Bool)
  }
}

extension CheckInComment {
  struct NewRequest: Encodable {
    let content: String
    let checkInId: Int

    enum CodingKeys: String, CodingKey {
      case content, checkInId = "check_in_id"
    }
  }

  struct UpdateRequest: Encodable {
    let id: Int
    let content: String
  }
}
