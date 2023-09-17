import EnvironmentModels
import Models
import Repositories
import SwiftUI

struct RouterWrapper<Content: View>: View {
    @Environment(\.repository) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var router: Router
    @State private var sheetEnvironmentModel = SheetManager()

    let content: (_ router: Router) -> Content

    init(tab: Tab, content: @escaping (_ router: Router) -> Content) {
        _router = State(wrappedValue: Router(tab: tab))
        self.content = content
    }

    var body: some View {
        @Bindable var feedbackEnvironmentModel = feedbackEnvironmentModel
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            content(router)
                .navigationDestination(for: Screen.self) { screen in
                    screen.view
                }
        }
        .onOpenURL { url in
            if let detailPage = url.detailPage {
                router.fetchAndNavigateTo(repository, detailPage, resetStack: true)
            }
        }
        .sheet(item: $sheetEnvironmentModel.sheet) { sheet in
            NavigationStack {
                sheet.view
            }
            .presentationDetents(sheet.detents)
            .presentationCornerRadius(sheet.cornerRadius)
            .presentationBackground(sheet.background)
            .presentationDragIndicator(.visible)
            .sheet(item: $sheetEnvironmentModel.nestedSheet, content: { nestedSheet in
                NavigationStack {
                    nestedSheet.view
                        .toast(isPresenting: $feedbackEnvironmentModel.show) {
                            feedbackEnvironmentModel.toast
                        }
                }
                .presentationDetents(nestedSheet.detents)
                .presentationCornerRadius(nestedSheet.cornerRadius)
                .presentationBackground(nestedSheet.background)
                .presentationDragIndicator(.visible)
            })
            .toast(isPresenting: $feedbackEnvironmentModel.show) {
                feedbackEnvironmentModel.toast
            }
        }
        .toast(isPresenting: $feedbackEnvironmentModel.show) {
            feedbackEnvironmentModel.toast
        }
        .environment(router)
        .environment(sheetEnvironmentModel)
        .onChange(of: router.path) {
            router.storeState()
        }
    }
}
