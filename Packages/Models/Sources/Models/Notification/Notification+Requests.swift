import Foundation
public import Tagged

public extension Notification {
    struct CheckInTaggedProfiles: Identifiable, Codable {
        public let id: Notification.Id
        public let checkIn: CheckIn.Joined

        enum CodingKeys: String, CodingKey {
            case id
            case checkIn = "check_ins"
        }
    }

    struct MarkReadRequest: Codable, Sendable {
        public init(id: Notification.Id) {
            self.id = id
        }

        public let id: Notification.Id

        enum CodingKeys: String, CodingKey {
            case id = "p_notification_id"
        }
    }

    struct MarkCheckInReadRequest: Codable, Sendable {
        public init(checkInId: CheckIn.Id) {
            self.checkInId = checkInId
        }

        public let checkInId: CheckIn.Id

        enum CodingKeys: String, CodingKey {
            case checkInId = "p_check_in_id"
        }
    }
}
