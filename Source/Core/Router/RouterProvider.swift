import EnvironmentModels
import Models
import Repositories
import SwiftUI

struct RouterProvider<Content: View>: View {
    @Environment(Repository.self) private var repository
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @State private var feedbackEnvironmentModel = FeedbackEnvironmentModel()
    @State private var router = Router()

    let enableRoutingFromURLs: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        NavigationStack(path: $router.path) {
            content()
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(.ultraThinMaterial, for: .tabBar)
                .navigationDestination(for: Screen.self) { screen in
                    screen.view
                }
        }
        .injectSheets(item: $router.sheet)
        .injectFullScreenCovers(item: $router.fullScreenCover)
        .injectAlerts(item: $router.alert)
        .injectToasts(item: $feedbackEnvironmentModel.toast)
        .if(enableRoutingFromURLs) { view in
            view.onOpenURL { url in
                if let detailPage = DeepLinkHandler(url: url, deeplinkSchemes: appEnvironmentModel.infoPlist.deeplinkSchemes).detailPage {
                    router.fetchAndNavigateTo(repository, detailPage, resetStack: true)
                }
            }
        }
        .environment(router)
        .environment(feedbackEnvironmentModel)
        .sensoryFeedback(trigger: feedbackEnvironmentModel.sensoryFeedback) { _, newValue in
            newValue?.sensoryFeedback
        }
    }
}
