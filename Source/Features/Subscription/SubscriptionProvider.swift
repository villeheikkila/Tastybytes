import OSLog
import StoreKit
import SwiftUI

struct SubscriptionProvider<Content: View>: View {
    @Environment(\.productSubscriptionIds) private var productSubscriptionIds
    @State private var subscriptionEnvironmentModel = SubscriptionEnvironmentModel()
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .environment(subscriptionEnvironmentModel)
            .subscriptionStatusTask(for: productSubscriptionIds.group) { taskStatus in
                await subscriptionEnvironmentModel.onTaskStatusChange(taskStatus: taskStatus, productSubscriptionIds: productSubscriptionIds)
            }
            .task {
                await subscriptionEnvironmentModel.productSubscription.observeTransactionUpdates()
                await subscriptionEnvironmentModel.productSubscription.checkForUnfinishedTransactions()
            }
    }
}
