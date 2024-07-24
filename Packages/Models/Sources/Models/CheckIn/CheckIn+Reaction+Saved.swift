public import Tagged

public extension CheckIn.Reaction {
    struct Saved: Identifiable, Codable, Hashable, Sendable {
        public let id: CheckIn.Reaction.Id
        public let profile: Profile.Saved

        enum CodingKeys: String, CodingKey {
            case id
            case profile = "profiles"
        }
    }
}
