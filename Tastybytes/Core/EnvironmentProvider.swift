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
    @State private var authEvent: AuthChangeEvent?
    @State private var orientation: UIDeviceOrientation
    @Environment(\.repository) private var repository
    @State private var feedbackEnvironmentModel: FeedbackEnvironmentModel

    init(repository: Repository) {
        let feedbackEnvironmentModel = FeedbackEnvironmentModel()
        let notificationModel = NotificationEnvironmentModel(repository: repository)
        let profileModel = ProfileEnvironmentModel(repository: repository)
        let appDataModel = AppDataEnvironmentModel(repository: repository)
        let imageUploadModel = ImageUploadEnvironmentModel(repository: repository)
        let friendModel = FriendEnvironmentModel(repository: repository)

        _notificationEnvironmentModel =
            State(wrappedValue: notificationModel)
        _profileEnvironmentModel =
            State(wrappedValue: profileModel)
        _appDataEnvironmentModel =
            State(wrappedValue: appDataModel)
        _imageUploadEnvironmentModel =
            State(wrappedValue: imageUploadModel)
        _friendEnvironmentModel =
            State(wrappedValue: friendModel)
        _orientation = State(wrappedValue: UIDevice.current.orientation)
        _feedbackEnvironmentModel = State(wrappedValue: feedbackEnvironmentModel)
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
            .detectOrientation($orientation)
            .environment(\.orientation, orientation)
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
