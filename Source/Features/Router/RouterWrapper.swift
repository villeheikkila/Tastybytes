import EnvironmentModels
import Models
import Repositories
import SwiftUI

@MainActor
struct RouterWrapper<Content: View>: View {
    @Environment(Repository.self) private var repository
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var router = Router()

    @ViewBuilder let content: () -> Content

    var body: some View {
        @Bindable var feedbackEnvironmentModel = feedbackEnvironmentModel
        NavigationStack(path: $router.path) {
            content()
                .toolbarBackground(Material.thin, for: .navigationBar)
                .toolbarBackground(Material.thin, for: .tabBar)
                .navigationDestination(for: Screen.self) { screen in
                    screen.view
                }
        }
        .onOpenURL { url in
            if let detailPage = DeepLinkHandler(url: url, deeplinkSchemes: appEnvironmentModel.infoPlist.deeplinkSchemes).detailPage {
                router.fetchAndNavigateTo(repository, detailPage, resetStack: true)
            }
        }
        .toast(isPresenting: $feedbackEnvironmentModel.show) {
            feedbackEnvironmentModel.toast
        }
        .environment(router)
        .sensoryFeedback(trigger: feedbackEnvironmentModel.sensoryFeedback) { _, newValue in
            newValue?.sensoryFeedback
        }
    }
}
