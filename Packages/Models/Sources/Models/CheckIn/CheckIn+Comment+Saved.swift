import Foundation
public import Tagged

public extension CheckIn.Comment {
    struct Saved: Identifiable, Hashable, Codable, Sendable, CheckInCommentProtocol {
        public let id: CheckIn.Comment.Id
        public let content: String
        public let createdAt: Date
        public let profile: Profile.Saved

        enum CodingKeys: String, CodingKey {
            case id
            case content
            case createdAt = "created_at"
            case profile = "profiles"
        }
    }
}
