import EnvironmentModels
import Models
import Repositories
import SwiftUI

struct RouterProvider<Content: View>: View {
    @Environment(Repository.self) private var repository

    let enableRoutingFromURLs: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        RouterInnerProvider(repository: repository, enableRoutingFromURLs: enableRoutingFromURLs, content: content)
    }
}

private struct RouterInnerProvider<Content: View>: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @State private var router: Router

    let enableRoutingFromURLs: Bool
    @ViewBuilder let content: () -> Content

    init(
        repository: Repository,
        enableRoutingFromURLs: Bool,
        content: @escaping () -> Content
    ) {
        _router = State(wrappedValue: Router(repository: repository))
        self.enableRoutingFromURLs = enableRoutingFromURLs
        self.content = content
    }

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
        .injectToasts(item: $router.toast.map(getter: { toastType in toastType?.toastEvent }, setter: { _ in
            nil
        }))
        .if(enableRoutingFromURLs) { view in
            view.onOpenURL { url in
                if let detailPage = DeepLinkHandler(url: url, deeplinkSchemes: appEnvironmentModel.infoPlist.deeplinkSchemes).detailPage {
                    router.open(.navigatablePath(detailPage, resetStack: true))
                }
            }
        }
        .environment(router)
    }
}
