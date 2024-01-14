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
        public let subscriptions: [Subscription]

        enum CodingKeys: String, CodingKey {
            case name
            case groupId = "group_id"
            case subscriptions
        }
    }
}

public struct Subscription: Hashable, Codable, Sendable, Comparable {
    public let name: String
    public let id: String
    public let groupId: String
    public let priority: Int

    enum CodingKeys: String, CodingKey {
        case name
        case id = "product_id"
        case groupId = "group_id"
        case priority
    }

    public static func < (lhs: Subscription, rhs: Subscription) -> Bool {
        lhs.priority < rhs.priority
    }
}
