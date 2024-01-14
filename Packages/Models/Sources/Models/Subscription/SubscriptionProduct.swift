public struct SubscriptionProduct: Hashable, Codable, Sendable, Comparable {
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

    public static func < (lhs: SubscriptionProduct, rhs: SubscriptionProduct) -> Bool {
        lhs.priority < rhs.priority
    }
}
