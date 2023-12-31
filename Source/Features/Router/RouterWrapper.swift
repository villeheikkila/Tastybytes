import EnvironmentModels
import Models
import Repositories
import SwiftUI

@MainActor
struct RouterWrapper<Content: View>: View {
    @Environment(\.repository) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var router = Router()
    @State private var sheetEnvironmentModel = SheetManager()

    @ViewBuilder let content: () -> Content

    var body: some View {
        @Bindable var feedbackEnvironmentModel = feedbackEnvironmentModel
        NavigationStack(path: $router.path) {
            content()
                .navigationDestination(for: Screen.self) { screen in
                    screen.view
                }
        }
        .onOpenURL { url in
            if let detailPage = url.detailPage {
                router.fetchAndNavigateTo(repository, detailPage, resetStack: true)
            }
        }
        .sheets(item: $sheetEnvironmentModel.sheet)
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
        .toast(isPresenting: $feedbackEnvironmentModel.show) {
            feedbackEnvironmentModel.toast
        }
        .environment(router)
        .environment(sheetEnvironmentModel)
        .sensoryFeedback(trigger: feedbackEnvironmentModel.sensoryFeedback) { _, newValue in
            newValue?.sensoryFeedback
        }
    }
}
