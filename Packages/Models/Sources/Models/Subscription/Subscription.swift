public struct SubscriptionGroup: Hashable, Codable, Sendable {
    public let groupId: String

    enum CodingKeys: String, CodingKey {
        case groupId = "group_id"
    }
}

public struct Subscription: Hashable, Codable, Sendable {
    public let groupId: String
    public let productId: String

    enum CodingKeys: String, CodingKey {
        case groupId = "group_id"
        case productId = "product_id"
    }
}
