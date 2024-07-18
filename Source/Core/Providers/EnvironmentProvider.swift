import EnvironmentModels
import Models
import OSLog
import Repositories
import StoreKit
import SwiftUI
import TipKit

struct EnvironmentProvider<Content: View>: View {
    @State private var adminEnvironmentModel: AdminEnvironmentModel
    @State private var profileEnvironmentModel: ProfileEnvironmentModel
    @State private var notificationEnvironmentModel: NotificationEnvironmentModel
    @State private var appEnvironmentModel: AppEnvironmentModel
    @State private var friendEnvironmentModel: FriendEnvironmentModel
    @State private var imageUploadEnvironmentModel: ImageUploadEnvironmentModel
    @State private var locationEnvironmentModel = LocationEnvironmentModel()
    @State private var subscriptionEnvironmentModel: SubscriptionEnvironmentModel
    @State private var feedbackEnvironmentModel = FeedbackEnvironmentModel()
    @ViewBuilder let content: () -> Content

    init(repository: Repository, infoPlist: InfoPlist, content: @escaping () -> Content) {
        adminEnvironmentModel = AdminEnvironmentModel(repository: repository)
        profileEnvironmentModel = ProfileEnvironmentModel(repository: repository)
        notificationEnvironmentModel = NotificationEnvironmentModel(repository: repository)
        appEnvironmentModel = AppEnvironmentModel(repository: repository, infoPlist: infoPlist)
        friendEnvironmentModel = FriendEnvironmentModel(repository: repository)
        imageUploadEnvironmentModel = ImageUploadEnvironmentModel(repository: repository)
        subscriptionEnvironmentModel = SubscriptionEnvironmentModel(repository: repository)
        self.content = content
    }

    var body: some View {
        content()
            .environment(adminEnvironmentModel)
            .environment(notificationEnvironmentModel)
            .environment(profileEnvironmentModel)
            .environment(appEnvironmentModel)
            .environment(friendEnvironmentModel)
            .environment(imageUploadEnvironmentModel)
            .environment(locationEnvironmentModel)
            .environment(subscriptionEnvironmentModel)
            .environment(feedbackEnvironmentModel)
            .sensoryFeedback(trigger: feedbackEnvironmentModel.sensoryFeedback) { _, newValue in
                newValue?.sensoryFeedback
            }
            // .alertError($appEnvironmentModel.alertError)
            // .alertError($notificationEnvironmentModel.alertError)
            // .alertError($profileEnvironmentModel.alertError)
            // .alertError($appEnvironmentModel.alertError)
            // .alertError($friendEnvironmentModel.alertError)
            .task {
                try? Tips.configure([.displayFrequency(.daily)])
            }
            .task {
                await appEnvironmentModel.initialize()
            }
            .task {
                await profileEnvironmentModel.listenToAuthState()
            }
            .task {
                locationEnvironmentModel.updateLocationAuthorizationStatus()
            }
    }
}
