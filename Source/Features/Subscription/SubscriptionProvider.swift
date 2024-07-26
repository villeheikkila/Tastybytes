
import OSLog
import StoreKit
import SwiftUI

struct SubscriptionProvider<Content: View>: View {
    @Environment(AppModel.self) private var appModel
    @Environment(SubscriptionModel.self) private var subscriptionModel
    @ViewBuilder let content: () -> Content

    var body: some View {
        Group {
            if let subscriptionGroup = appModel.subscriptionGroup {
                content()
                    .subscriptionStatusTask(for: subscriptionGroup.groupId) { taskStatus in
                        await subscriptionModel.onTaskStatusChange(taskStatus: taskStatus, productSubscriptions: subscriptionGroup.subscriptions)
                    }
                    .task {
                        await subscriptionModel.initializeActiveTransactions()
                    }
                    .task {
                        await subscriptionModel.productSubscription.observeTransactionUpdates()
                    }
                    .task {
                        await subscriptionModel.productSubscription.checkForUnfinishedTransactions()
                    }
            }
        }
    }
}
