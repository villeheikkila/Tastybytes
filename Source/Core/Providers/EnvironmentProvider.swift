import EnvironmentModels
import Models
import OSLog
import Repositories
import StoreKit
import SwiftUI
import TipKit

struct EnvironmentProvider<Content: View>: View {
    @AppStorage(.colorScheme) var colorScheme: String = "system"
    @State private var profileEnvironmentModel: ProfileEnvironmentModel
    @State private var notificationEnvironmentModel: NotificationEnvironmentModel
    @State private var appEnvironmentModel: AppEnvironmentModel
    @State private var friendEnvironmentModel: FriendEnvironmentModel
    @State private var imageUploadEnvironmentModel: ImageUploadEnvironmentModel
    @State private var locationEnvironmentModel: LocationEnvironmentModel
    @State private var feedbackEnvironmentModel: FeedbackEnvironmentModel
    @State private var subscriptionEnvironmentModel: SubscriptionEnvironmentModel

    let repository: Repository

    init(repository: Repository, infoPlist: InfoPlist, content: @escaping () -> Content) {
        profileEnvironmentModel = ProfileEnvironmentModel(repository: repository)
        notificationEnvironmentModel = NotificationEnvironmentModel(repository: repository)
        appEnvironmentModel = AppEnvironmentModel(repository: repository, infoPlist: infoPlist)
        friendEnvironmentModel = FriendEnvironmentModel(repository: repository)
        imageUploadEnvironmentModel = ImageUploadEnvironmentModel(repository: repository)
        locationEnvironmentModel = LocationEnvironmentModel()
        feedbackEnvironmentModel = FeedbackEnvironmentModel()
        subscriptionEnvironmentModel = SubscriptionEnvironmentModel(repository: repository)
        self.content = content
        self.repository = repository
    }

    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .environment(notificationEnvironmentModel)
            .environment(profileEnvironmentModel)
            .environment(feedbackEnvironmentModel)
            .environment(appEnvironmentModel)
            .environment(friendEnvironmentModel)
            .environment(imageUploadEnvironmentModel)
            .environment(locationEnvironmentModel)
            .environment(subscriptionEnvironmentModel)
            .alertError($appEnvironmentModel.alertError)
            .alertError($notificationEnvironmentModel.alertError)
            .alertError($profileEnvironmentModel.alertError)
            .alertError($appEnvironmentModel.alertError)
            .alertError($friendEnvironmentModel.alertError)
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
