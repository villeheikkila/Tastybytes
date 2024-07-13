import Foundation
import Models

public protocol SubscriptionRepository: Sendable {
    func getActiveGroup() async throws -> SubscriptionGroup.Joined
    func syncSubscriptionTransaction(transactionInfo: SubscriptionTransaction) async throws
}
