public struct Summary: Codable, Hashable, Sendable {
    public let totalCheckIns: Int
    public let averageRating: Double?
    public let friendsTotalCheckIns: Int
    public let friendsAverageRating: Double?
    public let currentUserTotalCheckIns: Int
    public let currentUserAverageRating: Double?

    public var isEmpty: Bool {
        averageRating == nil && friendsAverageRating == nil && currentUserAverageRating == nil
    }

    enum CodingKeys: String, CodingKey {
        case totalCheckIns = "total_check_ins"
        case averageRating = "average_rating"
        case friendsTotalCheckIns = "friends_check_ins"
        case friendsAverageRating = "friends_average_rating"
        case currentUserTotalCheckIns = "current_user_check_ins"
        case currentUserAverageRating = "current_user_average_rating"
    }
}
