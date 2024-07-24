public import Tagged

public extension CheckIn.Reaction {
    struct NewRequest: Codable, Sendable {
        public init(checkInId: CheckIn.Id) {
            self.checkInId = checkInId
        }

        public let checkInId: CheckIn.Id

        enum CodingKeys: String, CodingKey {
            case checkInId = "p_check_in_id"
        }
    }

    struct DeleteRequest: Codable, Sendable {
        public init(id: CheckIn.Reaction.Id) {
            self.id = id
        }

        public let id: CheckIn.Reaction.Id

        enum CodingKeys: String, CodingKey {
            case id = "p_check_in_reaction_id"
        }
    }
}
