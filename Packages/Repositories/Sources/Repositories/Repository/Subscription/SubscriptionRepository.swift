import Foundation
import Models

public protocol SubscriptionRepository: Sendable {
    func getActiveGroup() async -> Result<SubscriptionGroup.Joined, Error>
    func syncSubscriptionTransaction(transactionInfo: SubscriptionTransaction) async -> Result<Void, Error>
}
