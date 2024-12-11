import Foundation
import Models

public protocol SubscriptionRepository: Sendable {
    func getActiveGroup() async throws -> SubscriptionGroup.Joined
}
