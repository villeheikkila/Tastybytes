
import Models
import Repositories
import SwiftUI

struct RouterProvider<Content: View>: View {
    @Environment(AppModel.self) private var appModel
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
        .injectToasts(item: $router.toast.map(getter: { toastType in toastType?.toastEvent }, setter: { _ in
            nil
        }))
        .if(enableRoutingFromURLs) { view in
            view.onOpenURL { url in
                if let path = DeepLinkHandler(url: url, deeplinkSchemes: appModel.infoPlist.deeplinkSchemes).detailPage {
                    router.open(path.open)
                }
            }
        }
        .environment(router)
    }
}

extension NavigatablePath {
    var open: Router.Open {
        switch self {
        case let .product(id):
            .screen(.product(id))
        case let .productWithBarcode(id, barcode):
            .screen(.productFromBarcode(id, barcode))
        case let .checkIn(id):
            .screen(.checkIn(id))
        case let .company(id):
            .screen(.company(id))
        case let .brand(id):
            .screen(.brand(id))
        case let .profile(id):
            .screen(.profileById(id))
        case let .location(id):
            .screen(.location(id))
        }
    }
}
