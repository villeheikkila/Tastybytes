import EnvironmentModels
import Models
import Repositories
import SwiftUI

struct RouterProvider<Content: View>: View {
    @Environment(Repository.self) private var repository
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var router = Router()

    let isRootLevelNavigationStack: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        @Bindable var feedbackEnvironmentModel = feedbackEnvironmentModel
        NavigationStack(path: $router.path) {
            content()
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(.ultraThinMaterial, for: .tabBar)
                .navigationDestination(for: Screen.self) { screen in
                    screen.view
                }
        }
        .sheets(item: $router.sheet)
        .alertError($router.alert)
        .if(isRootLevelNavigationStack) { view in
            view.onOpenURL { url in
                if let detailPage = DeepLinkHandler(url: url, deeplinkSchemes: appEnvironmentModel.infoPlist.deeplinkSchemes).detailPage {
                    router.fetchAndNavigateTo(repository, detailPage, resetStack: true)
                }
            }
        }
        .toasts(presenting: $feedbackEnvironmentModel.toast)
        .environment(router)
        .sensoryFeedback(trigger: feedbackEnvironmentModel.sensoryFeedback) { _, newValue in
            newValue?.sensoryFeedback
        }
    }
}
