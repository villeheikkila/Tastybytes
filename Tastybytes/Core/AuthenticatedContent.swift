import EnvironmentModels
import OSLog
import Repositories
import StoreKit
import SwiftUI
import TipKit

struct AuthenticatedContent: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @AppStorage(.isOnboardedOnDevice) private var isOnboardedOnDevice = false

    var body: some View {
        if !profileEnvironmentModel.isLoggedIn {
            EmptyView()
        } else if !isOnboardedOnDevice {
            OnboardingScreen()
        } else {
            MainContent()
        }
    }
}

struct MainContent: View {
    private let logger = Logger(category: "MainContent")
    @State private var status: EntitlementTaskState<SubscriptionStatus> = .loading
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(NotificationEnvironmentModel.self) private var notificationEnvironmentModel
    @Environment(SubscriptionEnvironmentModel.self) private var subscriptionEnvironmentModel
    @Environment(\.scenePhase) private var phase
    @Environment(\.productSubscriptionIds) private var productSubscriptionIds

    var body: some View {
        Group {
            if isPadOrMac() {
                SideBarView()
            } else {
                TabsView()
            }
        }
        .onChange(of: phase) { _, newPhase in
            if newPhase == .active {
                Task { await notificationEnvironmentModel.getUnreadCount()
                }
            }
        }
        .onReceive(NotificationCenter.default
            .publisher(for: NSNotification.Name(rawValue: "PushNotificationReceived")))
        { notification in
            guard let userInfo = notification.userInfo, let aps = userInfo["aps"] as? [String: Any],
                  let unreadCount = aps["badge"] as? Int else { return }
            notificationEnvironmentModel.unreadCount = unreadCount
        }
        .task {
            await friendEnvironmentModel.initialize(profile: profileEnvironmentModel.profile)
            await notificationEnvironmentModel.getUnreadCount()
        }
        .onAppear(perform: {
            ProductSubscription.createSharedInstance()
        })
        .subscriptionStatusTask(for: productSubscriptionIds.group) { taskStatus in
            self.status = await taskStatus.map { statuses in
                await ProductSubscription.shared.status(
                    for: statuses,
                    ids: productSubscriptionIds
                )
            }
            switch self.status {
            case let .failure(error):
                subscriptionEnvironmentModel.subscriptionStatus = .notSubscribed
                logger.error("Failed to check subscription status: \(error)")
            case let .success(status):
                subscriptionEnvironmentModel.subscriptionStatus = status
            case .loading: break
            @unknown default: break
            }
        }
        .task {
            await ProductSubscription.shared.observeTransactionUpdates()
            await ProductSubscription.shared.checkForUnfinishedTransactions()
        }
    }
}
