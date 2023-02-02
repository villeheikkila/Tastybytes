import Foundation

struct Friend: Identifiable, Decodable {
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

extension Friend: Hashable {
  static func == (lhs: Friend, rhs: Friend) -> Bool {
    lhs.id == rhs.id && lhs.status == rhs.status
  }
}

extension Friend {
  enum Status: String, Codable {
    case pending, accepted, blocked
  }

  struct NewRequest: Encodable {
    let user_id_2: UUID
    let status: String
    init(receiver: UUID, status _: Status) {
      user_id_2 = receiver
      status = Status.pending.rawValue
    }
  }

  struct UpdateRequest: Encodable {
    let user_id_1: UUID
    let user_id_2: UUID
    let status: String

    init(sender: Profile, receiver: Profile, status: Status) {
      user_id_1 = sender.id
      user_id_2 = receiver.id
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
