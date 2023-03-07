import Foundation

struct CheckInComment: Identifiable, Hashable, Decodable, Sendable {
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
      return queryWithTableName(tableName, joinWithComma(saved, Profile.getQuery(.minimal(true))), withTableName)
    }
  }

  enum QueryType {
    case tableName
    case joinedProfile(_ withTableName: Bool)
  }
}

extension CheckInComment {
  struct NewRequest: Encodable, Sendable {
    let content: String
    let checkInId: Int

    enum CodingKeys: String, CodingKey {
      case content, checkInId = "check_in_id"
    }
  }

  struct UpdateRequest: Encodable, Sendable {
    let id: Int
    let content: String
  }
}
