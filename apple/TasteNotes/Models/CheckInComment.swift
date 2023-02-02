import Foundation

struct CheckInComment: Identifiable {
  let id: Int
  var content: String
  let createdAt: Date
  let profile: Profile
}

extension CheckInComment: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(content)
  }

  static func == (lhs: CheckInComment, rhs: CheckInComment) -> Bool {
    lhs.id == rhs.id && lhs.content == rhs.content
  }
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
    let check_in_id: Int

    init(content: String, checkInId: Int) {
      self.content = content
      check_in_id = checkInId
    }
  }

  struct UpdateRequest: Encodable {
    let id: Int
    let content: String
  }
}
