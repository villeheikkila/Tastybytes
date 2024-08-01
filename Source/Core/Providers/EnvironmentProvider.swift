
import Models
import OSLog
import Repositories
import StoreKit
import SwiftUI
import TipKit

struct EnvironmentProvider<Content: View>: View {
    @State private var adminModel: AdminModel
    @State private var profileModel: ProfileModel
    @State private var appModel: AppModel
    @State private var checkInUploadModel: CheckInUploadModel
    @State private var locationModel = LocationModel()
    @State private var subscriptionModel: SubscriptionModel
    @State private var feedbackModel = FeedbackModel()
    @ViewBuilder let content: () -> Content

    init(repository: Repository, infoPlist: InfoPlist, content: @escaping () -> Content) {
        adminModel = AdminModel(repository: repository)
        profileModel = ProfileModel(repository: repository)
        appModel = AppModel(repository: repository, infoPlist: infoPlist)
        checkInUploadModel = CheckInUploadModel(repository: repository)
        subscriptionModel = SubscriptionModel(repository: repository)
        self.content = content
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
            .sensoryFeedback(trigger: feedbackModel.sensoryFeedback) { _, newValue in
                newValue?.sensoryFeedback
            }
            // .alertError($appModel.alertError)
            // .alertError($notificationModel.alertError)
            // .alertError($profileModel.alertError)
            // .alertError($appModel.alertError)
            // .alertError($friendModel.alertError)
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
    }
}
