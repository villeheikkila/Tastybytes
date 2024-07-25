public import Tagged

public extension Profile {
    struct TimePeriodStatistic: Codable, Sendable {
        public enum TimePeriod: String, CaseIterable, Sendable {
            case week, month, year, all
        }

        public let checkIns: Int
        public let newUniqueProducts: Int

        enum CodingKeys: String, CodingKey {
            case checkIns = "check_ins"
            case newUniqueProducts = "new_unique_products"
        }

        public struct RequestParams: Codable, Sendable {
            public init(userId: Profile.Id, timePeriod: StatisticsTimePeriod) {
                self.userId = userId
                self.timePeriod = timePeriod.rawValue
            }

            public let userId: Profile.Id
            public let timePeriod: String

            enum CodingKeys: String, CodingKey {
                case userId = "p_user_id"
                case timePeriod = "p_time_period"
            }
        }
    }
}
