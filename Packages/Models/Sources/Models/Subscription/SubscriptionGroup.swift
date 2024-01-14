public struct SubscriptionGroup: Hashable, Codable, Sendable {
    public let name: String
    public let id: String

    enum CodingKeys: String, CodingKey {
        case name
        case id = "group_id"
    }
}

public extension SubscriptionGroup {
    struct Joined: Hashable, Codable, Sendable {
        public let name: String
        public let groupId: String
        public let subscriptions: [SubscriptionProduct]

        enum CodingKeys: String, CodingKey {
            case name
            case groupId = "group_id"
            case subscriptions = "subscription_products"
        }
    }
}
