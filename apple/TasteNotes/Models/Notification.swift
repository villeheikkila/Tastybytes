import Foundation

enum NotificationContent: Hashable {
  case message(String)
  case friendRequest(Friend)
  case taggedCheckIn(CheckIn)
  case checkInReaction(CheckInReaction.JoinedCheckIn)
}

struct Notification: Identifiable {
  let id: Int
  let createdAt: Date
  let seenAt: Date?
  let content: NotificationContent
}

extension Notification {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "notifications"
    let saved = "id, message, created_at, seen_at"

    switch queryType {
    case .tableName:
      return tableName
    case .joined:
      return joinWithComma(
        saved,
        CheckInReaction.getQuery(.joinedProfileCheckIn(true)),
        CheckInTaggedProfiles.getQuery(.joined(true)),
        Friend.getQuery(.joined(true))
      )
    }
  }

  enum QueryType {
    case tableName
    case joined
  }
}

extension Notification: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(seenAt)
  }

  static func == (lhs: Notification, rhs: Notification) -> Bool {
    lhs.id == rhs.id && lhs.seenAt == rhs.seenAt
  }
}

extension Notification: Decodable {
  enum CodingKeys: String, CodingKey {
    case id
    case message
    case createdAt = "created_at"
    case seenAt = "seen_at"
    case friendRequest = "friends"
    case taggedCheckIn = "check_in_tagged_profiles"
    case checkInReaction = "check_in_reactions"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(Int.self, forKey: .id)
    createdAt = try parseDate(from: try values.decode(String.self, forKey: .createdAt))

    if let date = try values.decodeIfPresent(String.self, forKey: .seenAt) {
      seenAt = try parseDate(from: date)
    } else {
      seenAt = nil
    }

    let message = try values.decodeIfPresent(String.self, forKey: .message)
    let friendRequest = try values.decodeIfPresent(Friend.self, forKey: .friendRequest)
    let taggedCheckIn = try values.decodeIfPresent(CheckInTaggedProfiles.self, forKey: .taggedCheckIn)
    let checkInReaction = try values.decodeIfPresent(CheckInReaction.JoinedCheckIn.self, forKey: .checkInReaction)

    if let message {
      content = NotificationContent.message(message)
    } else if let friendRequest {
      content = NotificationContent.friendRequest(friendRequest)
    } else if let checkIn = taggedCheckIn?.checkIn {
      content = NotificationContent.taggedCheckIn(checkIn)
    } else if let checkInReaction {
      content = NotificationContent.checkInReaction(checkInReaction)
    } else {
      content = NotificationContent.message("No content")
    }
  }
}

extension Notification {
  struct CheckInTaggedProfiles: Identifiable, Decodable {
    let id: Int
    let checkIn: CheckIn

    static func == (lhs: CheckInTaggedProfiles, rhs: CheckInTaggedProfiles) -> Bool {
      lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
      case id
      case checkIn = "check_ins"
    }

    init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      id = try values.decode(Int.self, forKey: .id)
      checkIn = try values.decode(CheckIn.self, forKey: .checkIn)
    }

    static func getQuery(_ queryType: QueryType) -> String {
      let tableName = "check_in_tagged_profiles"
      let saved = "id"

      switch queryType {
      case .tableName:
        return tableName
      case let .joined(withTableName):
        return queryWithTableName(tableName, joinWithComma(saved, CheckIn.getQuery(.joined(true))), withTableName)
      }
    }

    enum QueryType {
      case tableName
      case joined(_ withTableName: Bool)
    }
  }

  struct MarkReadRequest: Encodable {
    let p_notification_id: Int

    init(id: Int) {
      p_notification_id = id
    }
  }

  struct MarkCheckInReadRequest: Encodable {
    let p_check_in_id: Int

    init(checkInId: Int) {
      p_check_in_id = checkInId
    }
  }
}
