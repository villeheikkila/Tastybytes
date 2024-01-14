import EnvironmentModels
import Models
import OSLog
import Repositories
import StoreKit
import SwiftUI

@MainActor
struct EnvironmentProvider<Content: View>: View {
    @State private var permissionEnvironmentModel = PermissionEnvironmentModel()
    @State private var profileEnvironmentModel = ProfileEnvironmentModel(repository: RepositoryInitializer.shared.repository)
    @State private var notificationEnvironmentModel = NotificationEnvironmentModel(repository: RepositoryInitializer.shared.repository)
    @State private var appEnvironmentModel = AppEnvironmentModel(repository: RepositoryInitializer.shared.repository, infoPlist: RepositoryInitializer.shared.infoPlist)
    @State private var friendEnvironmentModel = FriendEnvironmentModel(repository: RepositoryInitializer.shared.repository)
    @State private var imageUploadEnvironmentModel = ImageUploadEnvironmentModel(repository: RepositoryInitializer.shared.repository)
    @State private var locationEnvironmentModel = LocationEnvironmentModel()
    @State private var feedbackEnvironmentModel = FeedbackEnvironmentModel()
    @State private var subscriptionEnvironmentModel = SubscriptionEnvironmentModel(repository: RepositoryInitializer.shared.repository)

    let repository: Repository = RepositoryInitializer.shared.repository

    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .environment(repository)
            .environment(notificationEnvironmentModel)
            .environment(profileEnvironmentModel)
            .environment(feedbackEnvironmentModel)
            .environment(appEnvironmentModel)
            .environment(friendEnvironmentModel)
            .environment(permissionEnvironmentModel)
            .environment(imageUploadEnvironmentModel)
            .environment(locationEnvironmentModel)
            .environment(subscriptionEnvironmentModel)
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

private final class RepositoryInitializer {
    private let logger = Logger(category: "RepositoryInitializer")

    let infoPlist: InfoPlist
    let bundleIdentifier: String
    let repository: Repository

    static let shared = RepositoryInitializer()

    private init() {
        do {
            let startTime = DispatchTime.now()
            guard let infoDictionary = Bundle.main.infoDictionary else {
                throw NSError(domain: "Configuration", code: 0, userInfo: [NSLocalizedDescriptionKey: "infoDictionary not found"])
            }

            let jsonData = try JSONSerialization.data(withJSONObject: infoDictionary, options: .prettyPrinted)
            let infoPlist = try JSONDecoder().decode(InfoPlist.self, from: jsonData)
            let bundleIdentifier: String = Bundle.main.bundleIdentifier ?? "N/A"
            self.infoPlist = infoPlist
            self.bundleIdentifier = bundleIdentifier
            repository = Repository(
                supabaseURL: infoPlist.supabaseUrl,
                supabaseKey: infoPlist.supabaseAnonKey,
                headers: ["x_bundle_id": bundleIdentifier, "x_app_version": infoPlist.appVersion.prettyString]
            )
            logger.info("Repository initialized in \(startTime.elapsedTime())ms")
        } catch {
            fatalError("Failed to initialize repository: \(error)")
        }
    }
}
