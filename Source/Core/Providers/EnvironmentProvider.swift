import EnvironmentModels
import Models
import OSLog
import Repositories
import StoreKit
import SwiftUI
import TipKit

struct EnvironmentProvider<Content: View>: View {
    @AppStorage(.colorScheme) private var colorScheme: String = "system"
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
            .preferredColorScheme(CustomColorScheme(rawValue: colorScheme)?.systemColorScheme)
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
