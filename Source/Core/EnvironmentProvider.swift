import EnvironmentModels
import OSLog
import Repositories
import StoreKit
import SwiftUI
import TipKit

@MainActor
struct EnvironmentProvider<Content: View>: View {
    private let logger = Logger(category: "EnvironmentView")
    @State private var permissionEnvironmentModel = PermissionEnvironmentModel()
    @State private var profileEnvironmentModel: ProfileEnvironmentModel
    @State private var notificationEnvironmentModel: NotificationEnvironmentModel
    @State private var appDataEnvironmentModel: AppEnvironmentModel
    @State private var friendEnvironmentModel: FriendEnvironmentModel
    @State private var imageUploadEnvironmentModel: ImageUploadEnvironmentModel
    @State private var locationEnvironmentModel = LocationEnvironmentModel()
    @State private var feedbackEnvironmentModel = FeedbackEnvironmentModel()

    @ViewBuilder let content: () -> Content

    init(repository: Repository, @ViewBuilder content: @escaping () -> Content) {
        _notificationEnvironmentModel = State(wrappedValue: NotificationEnvironmentModel(repository: repository))
        _profileEnvironmentModel = State(wrappedValue: ProfileEnvironmentModel(repository: repository))
        _appDataEnvironmentModel = State(wrappedValue: AppEnvironmentModel(repository: repository))
        _imageUploadEnvironmentModel = State(wrappedValue: ImageUploadEnvironmentModel(repository: repository))
        _friendEnvironmentModel = State(wrappedValue: FriendEnvironmentModel(repository: repository))
        self.content = content
    }

    var body: some View {
        content()
            .environment(notificationEnvironmentModel)
            .environment(profileEnvironmentModel)
            .environment(feedbackEnvironmentModel)
            .environment(appDataEnvironmentModel)
            .environment(friendEnvironmentModel)
            .environment(permissionEnvironmentModel)
            .environment(imageUploadEnvironmentModel)
            .environment(locationEnvironmentModel)
            .alertError($appDataEnvironmentModel.alertError)
            .alertError($notificationEnvironmentModel.alertError)
            .alertError($profileEnvironmentModel.alertError)
            .alertError($appDataEnvironmentModel.alertError)
            .alertError($friendEnvironmentModel.alertError)
            .task {
                permissionEnvironmentModel.initialize()
            }
            .task {
                await appDataEnvironmentModel.initialize()
            }
            .task {
                locationEnvironmentModel.updateLocationAuthorizationStatus()
            }
            .task {
                try? Tips.configure([.displayFrequency(.daily)])
            }
    }
}

@MainActor
struct MiscProvider<Content: View>: View {
    @AppStorage(.colorScheme) var colorScheme: String = "system"
    @State private var isPortrait = false
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .preferredColorScheme(CustomColorScheme(rawValue: colorScheme)?.systemColorScheme)
            .detectOrientation($isPortrait)
            .environment(\.isPortrait, isPortrait)
    }
}
