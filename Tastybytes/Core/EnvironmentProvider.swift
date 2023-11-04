import EnvironmentModels
import OSLog
import Repositories
import StoreKit
import SwiftUI
import TipKit

private let logger = Logger(category: "EnvironmentView")

struct EnvironmentProvider: View {
    @AppStorage(.colorScheme) var colorScheme: String = "system"
    @State private var splashScreenEnvironmentModel = SplashScreenEnvironmentModel()
    @State private var permissionEnvironmentModel = PermissionEnvironmentModel()
    @State private var profileEnvironmentModel: ProfileEnvironmentModel
    @State private var notificationEnvironmentModel: NotificationEnvironmentModel
    @State private var appDataEnvironmentModel: AppDataEnvironmentModel
    @State private var friendEnvironmentModel: FriendEnvironmentModel
    @State private var imageUploadEnvironmentModel: ImageUploadEnvironmentModel
    @State private var subscriptionEnvironmentModel = SubscriptionEnvironmentModel()
    @State private var isPortrait = false
    @Environment(\.repository) private var repository
    @State private var feedbackEnvironmentModel = FeedbackEnvironmentModel()

    init(repository: Repository) {
        _notificationEnvironmentModel =
            State(wrappedValue: NotificationEnvironmentModel(repository: repository))
        _profileEnvironmentModel =
            State(wrappedValue: ProfileEnvironmentModel(repository: repository))
        _appDataEnvironmentModel =
            State(wrappedValue: AppDataEnvironmentModel(repository: repository))
        _imageUploadEnvironmentModel =
            State(wrappedValue: ImageUploadEnvironmentModel(repository: repository))
        _friendEnvironmentModel =
            State(wrappedValue: FriendEnvironmentModel(repository: repository))
    }

    var body: some View {
        AuthEventObserver()
            .environment(splashScreenEnvironmentModel)
            .environment(notificationEnvironmentModel)
            .environment(profileEnvironmentModel)
            .environment(feedbackEnvironmentModel)
            .environment(appDataEnvironmentModel)
            .environment(friendEnvironmentModel)
            .environment(permissionEnvironmentModel)
            .environment(imageUploadEnvironmentModel)
            .environment(subscriptionEnvironmentModel)
            .preferredColorScheme(CustomColorScheme(rawValue: colorScheme)?.systemColorScheme)
            .detectOrientation($isPortrait)
            .environment(\.isPortrait, isPortrait)
            .alertError($appDataEnvironmentModel.alertError)
            .alertError($notificationEnvironmentModel.alertError)
            .alertError($profileEnvironmentModel.alertError)
            .alertError($appDataEnvironmentModel.alertError)
            .alertError($friendEnvironmentModel.alertError)
            .task {
                try? Tips.configure([.displayFrequency(.daily)])
            }
            .task {
                permissionEnvironmentModel.initialize()
            }
            .task {
                await appDataEnvironmentModel.initialize()
            }
    }
}
