import Foundation
public import Tagged

public extension CheckIn.Comment {
    struct Detailed: Identifiable, Hashable, Decodable, Sendable, CheckInCommentProtocol, ModificationInfoCascaded {
        public let id: CheckIn.Comment.Id
        public let content: String
        public let checkIn: CheckIn.Joined
        public let reports: [Report.Joined]
        public let createdAt: Date
        public let createdBy: Profile.Saved
        public let updatedAt: Date?
        public let updatedBy: Profile.Saved?

        public var profile: Profile.Saved {
            createdBy
        }

        init(
            id: CheckIn.Comment.Id,
            content: String,
            checkIn: CheckIn.Joined,
            reports: [Report.Joined],
            createdAt: Date,
            createdBy: Profile.Saved,
            updatedAt: Date?,
            updatedBy: Profile.Saved?
        ) {
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
            reports: [Report.Joined]? = nil
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
}
