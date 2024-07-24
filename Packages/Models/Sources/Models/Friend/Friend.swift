import Foundation
public import Tagged

public enum Friend {}

public extension Friend {
    typealias Id = Tagged<Friend, Int>
}

public extension Friend {
    enum Status: String, Codable, Sendable {
        case pending, accepted, blocked
    }
}
