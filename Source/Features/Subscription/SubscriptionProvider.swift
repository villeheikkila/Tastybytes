import OSLog
import StoreKit
import SwiftUI

@MainActor
struct SubscriptionProvider<Content: View>: View {
    @Environment(SubscriptionEnvironmentModel.self) private var subscriptionEnvironmentModel
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .subscriptionStatusTask(for: subscriptionEnvironmentModel.subscriptionGroup?.groupId ?? "") { taskStatus in
                await subscriptionEnvironmentModel.onTaskStatusChange(taskStatus: taskStatus)
            }
            .task {
                await subscriptionEnvironmentModel.initializeProductIds()
            }
            .task {
                await subscriptionEnvironmentModel.productSubscription.observeTransactionUpdates()
                await subscriptionEnvironmentModel.productSubscription.checkForUnfinishedTransactions()
            }
    }
}
