import Foundation

public protocol CheckInCommentProtocol {
    var id: Int { get }
    var content: String { get }
    var createdAt: Date { get }
    var profile: Profile { get }
}

public struct CheckInComment: Identifiable, Hashable, Codable, Sendable, CheckInCommentProtocol {
    public let id: Int
    public let content: String
    public let createdAt: Date
    public let profile: Profile

    enum CodingKeys: String, CodingKey {
        case id
        case content
        case createdAt = "created_at"
        case profile = "profiles"
    }
}

public extension CheckInComment {
    struct Joined: Identifiable, Hashable, Codable, Sendable, CheckInCommentProtocol {
        public let id: Int
        public let content: String
        public let createdAt: Date
        public let profile: Profile
        public let checkIn: CheckIn

        public init(comment: CheckInComment, checkIn: CheckIn) {
            id = comment.id
            content = comment.content
            profile = comment.profile
            createdAt = comment.createdAt
            self.checkIn = checkIn
        }

        enum CodingKeys: String, CodingKey {
            case id
            case content
            case createdAt = "created_at"
            case profile = "profiles"
            case checkIn = "check_ins"
        }
    }

    struct NewRequest: Codable, Sendable {
        public init(content: String, checkInId: Int) {
            self.content = content
            self.checkInId = checkInId
        }

        public let content: String
        public let checkInId: Int

        enum CodingKeys: String, CodingKey {
            case content, checkInId = "check_in_id"
        }
    }

    struct DeleteAsAdminRequest: Codable, Sendable {
        public init(id: Int) {
            self.id = id
        }

        public let id: Int

        public init(comment: CheckInComment) {
            id = comment.id
        }

        enum CodingKeys: String, CodingKey {
            case id = "p_check_in_comment_id"
        }
    }

    struct UpdateRequest: Codable, Sendable {
        public init(id: Int, content: String) {
            self.id = id
            self.content = content
        }

        public let id: Int
        public let content: String
    }
}
