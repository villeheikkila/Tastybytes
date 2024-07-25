import Foundation

public extension Profile {
    struct CheckInsPerDay: Sendable, Codable, Identifiable {
        public var id: Double { checkInDate.timeIntervalSince1970 }

        public let checkInDate: Date
        public let numberOfCheckIns: Int
        public let uniqueProductCount: Int

        enum CodingKeys: String, CodingKey {
            case checkInDate = "check_in_date"
            case numberOfCheckIns = "number_of_check_ins"
            case uniqueProductCount = "unique_product_count"
        }
    }
}
