import Foundation
import Models

public protocol SubscriptionRepository: Sendable {
    func getActiveGroup() async -> Result<SubscriptionGroup.Joined, Error>
}
