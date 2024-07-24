public import Tagged

public extension CheckIn.Reaction {
    struct JoinedCheckIn: Identifiable, Hashable, Codable, Sendable {
        public let id: CheckIn.Reaction.Id
        public let profile: Profile.Saved
        public let checkIn: CheckIn.Joined

        enum CodingKeys: String, CodingKey {
            case id
            case profile = "profiles"
            case checkIn = "check_ins"
        }
    }
}
