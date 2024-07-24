import Foundation
public import Tagged

public extension CheckIn.Comment {
    struct Joined: Identifiable, Hashable, Codable, Sendable, CheckInCommentProtocol {
        public let id: CheckIn.Comment.Id
        public let content: String
        public let createdAt: Date
        public let profile: Profile.Saved
        public let checkIn: CheckIn.Joined

        public init(comment: CheckIn.Comment.Saved, checkIn: CheckIn.Joined) {
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
}
