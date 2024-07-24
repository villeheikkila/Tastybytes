public import Tagged

public extension CheckIn.Comment {
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
        public init(id: CheckIn.Comment.Id) {
            self.id = id
        }

        public let id: CheckIn.Comment.Id

        enum CodingKeys: String, CodingKey {
            case id = "p_check_in_comment_id"
        }
    }

    struct UpdateRequest: Codable, Sendable {
        public init(id: CheckIn.Comment.Id, content: String) {
            self.id = id
            self.content = content
        }

        public let id: CheckIn.Comment.Id
        public let content: String
    }
}
