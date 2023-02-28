import Foundation

struct Friend: Identifiable, Decodable, Hashable {
  let id: Int
  let sender: Profile
  let receiver: Profile
  let status: Status
  let blockedBy: UUID?

  enum CodingKeys: String, CodingKey {
    case id
    case sender
    case receiver
    case status
    case blockedBy = "blocked_by"
  }

  func getFriend(userId: UUID?) -> Profile {
    if sender.id == userId {
      return receiver
    } else {
      return sender
    }
  }

  func isPending(userId: UUID) -> Bool {
    receiver.id == userId && status == Status.pending
  }

  func isBlocked(userId: UUID) -> Bool {
    blockedBy != nil && blockedBy != userId
  }

  func containsUser(userId: UUID) -> Bool {
    sender.id == userId || receiver.id == userId
  }
}

extension Friend {
  enum Status: String, Codable {
    case pending, accepted, blocked
  }

  struct NewRequest: Encodable {
    let receiverId: UUID
    let status: String

    enum CodingKeys: String, CodingKey {
      case receiverId = "user_id_2", status
    }

    init(receiver: UUID, status _: Status) {
      receiverId = receiver
      status = Status.pending.rawValue
    }
  }

  struct UpdateRequest: Encodable {
    let senderId: UUID
    let receiverId: UUID
    let status: String

    enum CodingKeys: String, CodingKey {
      case senderId = "user_id_1", receiverId = "user_id_2", status
    }

    init(sender: Profile, receiver: Profile, status: Status) {
      senderId = sender.id
      receiverId = receiver.id
      self.status = status.rawValue
    }
  }
}

extension Friend {
  static func getQuery(_ queryType: QueryType) -> String {
    let tableName = "friends"
    let joined =
      """
        id, status, sender:user_id_1 (\(Profile.getQuery(.minimal(false)))),\
        receiver:user_id_2 (\(Profile.getQuery(.minimal(false))))
      """

    switch queryType {
    case .tableName:
      return tableName
    case let .joined(withTableName):
      return queryWithTableName(tableName, joined, withTableName)
    }
  }

  enum QueryType {
    case tableName
    case joined(_ withTableName: Bool)
  }
}
