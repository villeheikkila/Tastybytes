
import Logging
import Models
import Repositories
import StoreKit
import SwiftUI
import TipKit

struct EnvironmentProvider<Content: View>: View {
    @State private var snackController: SnackController
    @State private var adminModel: AdminModel
    @State private var profileModel: ProfileModel
    @State private var appModel: AppModel
    @State private var checkInUploadModel: CheckInUploadModel
    @State private var locationModel = LocationModel()
    @State private var subscriptionModel: SubscriptionModel
    @State private var feedbackModel = FeedbackModel()
    @ViewBuilder let content: () -> Content

    init(repository: Repository, infoPlist: InfoPlist, content: @escaping () -> Content) {
        let snackController = SnackController()
        adminModel = AdminModel(repository: repository, snackController: snackController)
        profileModel = ProfileModel(repository: repository, snackController: snackController)
        appModel = AppModel(repository: repository, infoPlist: infoPlist)
        checkInUploadModel = CheckInUploadModel(repository: repository)
        subscriptionModel = SubscriptionModel(repository: repository)
        self.content = content
        self.snackController = snackController
    }

    var body: some View {
        content()
            .environment(adminModel)
            .environment(profileModel)
            .environment(appModel)
            .environment(checkInUploadModel)
            .environment(locationModel)
            .environment(subscriptionModel)
            .environment(feedbackModel)
            .environment(snackController)
            .sensoryFeedback(trigger: feedbackModel.sensoryFeedback) { _, newValue in
                newValue?.sensoryFeedback
            }
            .task {
                try? Tips.configure([.displayFrequency(.daily)])
            }
            .task {
                await appModel.initialize()
            }
            .task {
                await profileModel.listenToAuthState()
            }
            .task {
                locationModel.updateLocationAuthorizationStatus()
            }
            .showPeriodicSnack(snackController: snackController)
            .onChange(of: subscriptionModel.subscriptionStatus, initial: true) {
                print("Subscription status: \(subscriptionModel.subscriptionStatus)")
            }
    }
}

extension View {
    func showPeriodicSnack(
        snackController: SnackController,
        isActive: Bool = true,
        interval: TimeInterval = 5.0
    ) -> some View {
        task {
            guard isActive else { return }

            while true {
                snackController.open(.init(
                    mode: .snack(
                        tint: .red,
                        systemName: "exclamationmark.triangle.fill",
                        message: "Unexpected error occurred"
                    )
                ))

                try? await Task.sleep(for: .seconds(interval))
            }
        }
    }
}
