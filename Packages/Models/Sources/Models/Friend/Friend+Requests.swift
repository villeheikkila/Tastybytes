public import Tagged

public extension Friend {
    struct NewRequest: Codable, Sendable {
        public init(receiver: Profile.Id, status: Status) {
            receiverId = receiver
            self.status = status.rawValue
        }

        public let receiverId: Profile.Id
        public let status: String

        enum CodingKeys: String, CodingKey {
            case receiverId = "user_id_2", status
        }

        public init(receiver: Profile.Id) {
            receiverId = receiver
            status = Status.pending.rawValue
        }
    }

    struct UpdateRequest: Codable, Sendable {
        public let senderId: Profile.Id
        public let receiverId: Profile.Id
        public let status: String

        enum CodingKeys: String, CodingKey {
            case senderId = "user_id_1", receiverId = "user_id_2", status
        }

        public init(sender: Profile, receiver: Profile, status: Status) {
            senderId = sender.id
            receiverId = receiver.id
            self.status = status.rawValue
        }
    }
}
