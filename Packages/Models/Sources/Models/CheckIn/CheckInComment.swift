import Foundation
import Tagged

public protocol CheckInCommentProtocol {
    var id: CheckInComment.Id { get }
    var content: String { get }
    var createdAt: Date { get }
    var profile: Profile { get }
}

public struct CheckInComment: Identifiable, Hashable, Codable, Sendable, CheckInCommentProtocol {
    public let id: CheckInComment.Id
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
    typealias Id = Tagged<CheckInComment, Int>
}

public extension CheckInComment {
    struct Joined: Identifiable, Hashable, Codable, Sendable, CheckInCommentProtocol {
        public let id: CheckInComment.Id
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

    struct Detailed: Identifiable, Hashable, Decodable, Sendable, CheckInCommentProtocol, ModificationInfoCascaded {
        public let id: CheckInComment.Id
        public let content: String
        public let checkIn: CheckIn
        public let reports: [Report]
        public let createdAt: Date
        public let createdBy: Profile
        public let updatedAt: Date?
        public let updatedBy: Profile?

        public var profile: Profile {
            createdBy
        }

        init(id: CheckInComment.Id, content: String, checkIn: CheckIn, reports: [Report], createdAt: Date, createdBy: Profile, updatedAt: Date?, updatedBy: Profile?) {
            self.id = id
            self.content = content
            self.checkIn = checkIn
            self.reports = reports
            self.createdAt = createdAt
            self.createdBy = createdBy
            self.updatedAt = updatedAt
            self.updatedBy = updatedBy
        }

        public init() {
            id = .init(0)
            content = ""
            checkIn = .init()
            reports = []
            createdAt = Date.now
            createdBy = .init()
            updatedAt = nil
            updatedBy = nil
        }

        enum CodingKeys: String, CodingKey {
            case id
            case content
            case checkIn = "check_ins"
            case reports
            case createdAt = "created_at"
            case createdBy = "created_by"
            case updatedAt = "updated_at"
            case updatedBy = "updated_by"
        }

        public func copyWith(
            reports: [Report]? = nil
        ) -> Self {
            .init(
                id: id,
                content: content,
                checkIn: checkIn,
                reports: reports ?? self.reports,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy
            )
        }
    }

    struct NewRequest: Codable, Sendable {
        public init(content: String, checkInId: CheckIn.Id) {
            self.content = content
            self.checkInId = checkInId
        }

        public let content: String
        public let checkInId: CheckIn.Id

        enum CodingKeys: String, CodingKey {
            case content, checkInId = "check_in_id"
        }
    }

    struct DeleteAsAdminRequest: Codable, Sendable {
        public init(id: CheckInComment.Id) {
            self.id = id
        }

        public let id: CheckInComment.Id

        enum CodingKeys: String, CodingKey {
            case id = "p_check_in_comment_id"
        }
    }

    struct UpdateRequest: Codable, Sendable {
        public init(id: CheckInComment.Id, content: String) {
            self.id = id
            self.content = content
        }

        public let id: CheckInComment.Id
        public let content: String
    }
}
