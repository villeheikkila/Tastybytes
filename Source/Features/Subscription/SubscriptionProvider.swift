import EnvironmentModels
import OSLog
import StoreKit
import SwiftUI

@MainActor
struct SubscriptionProvider<Content: View>: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(SubscriptionEnvironmentModel.self) private var subscriptionEnvironmentModel
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .subscriptionStatusTask(for: appEnvironmentModel.subscriptionGroup.groupId) { taskStatus in
                await subscriptionEnvironmentModel.onTaskStatusChange(taskStatus: taskStatus, productSubscriptions: appEnvironmentModel.subscriptionGroup.subscriptions)
            }
            .task {
                await subscriptionEnvironmentModel.productSubscription.observeTransactionUpdates()
                await subscriptionEnvironmentModel.productSubscription.checkForUnfinishedTransactions()
            }
    }
}
