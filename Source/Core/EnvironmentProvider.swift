import EnvironmentModels
import OSLog
import Repositories
import StoreKit
import SwiftUI

@MainActor
struct EnvironmentProvider<Content: View>: View {
    @State private var permissionEnvironmentModel = PermissionEnvironmentModel()
    @State private var profileEnvironmentModel: ProfileEnvironmentModel
    @State private var notificationEnvironmentModel: NotificationEnvironmentModel
    @State private var appEnvironmentModel: AppEnvironmentModel
    @State private var friendEnvironmentModel: FriendEnvironmentModel
    @State private var imageUploadEnvironmentModel: ImageUploadEnvironmentModel
    @State private var locationEnvironmentModel = LocationEnvironmentModel()
    @State private var feedbackEnvironmentModel = FeedbackEnvironmentModel()

    @ViewBuilder let content: () -> Content

    init(repository: Repository, @ViewBuilder content: @escaping () -> Content) {
        _notificationEnvironmentModel = State(wrappedValue: NotificationEnvironmentModel(repository: repository))
        _profileEnvironmentModel = State(wrappedValue: ProfileEnvironmentModel(repository: repository))
        _appEnvironmentModel = State(wrappedValue: AppEnvironmentModel(repository: repository))
        _imageUploadEnvironmentModel = State(wrappedValue: ImageUploadEnvironmentModel(repository: repository))
        _friendEnvironmentModel = State(wrappedValue: FriendEnvironmentModel(repository: repository))
        self.content = content
    }

    var body: some View {
        content()
            .environment(notificationEnvironmentModel)
            .environment(profileEnvironmentModel)
            .environment(feedbackEnvironmentModel)
            .environment(appEnvironmentModel)
            .environment(friendEnvironmentModel)
            .environment(permissionEnvironmentModel)
            .environment(imageUploadEnvironmentModel)
            .environment(locationEnvironmentModel)
            .alertError($appEnvironmentModel.alertError)
            .alertError($notificationEnvironmentModel.alertError)
            .alertError($profileEnvironmentModel.alertError)
            .alertError($appEnvironmentModel.alertError)
            .alertError($friendEnvironmentModel.alertError)
            .task {
                permissionEnvironmentModel.initialize()
            }
            .task {
                await appEnvironmentModel.initialize()
            }
            .task {
                locationEnvironmentModel.updateLocationAuthorizationStatus()
            }
    }
}
