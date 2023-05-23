import SwiftUI

struct RouterWrapper<Content: View>: View {
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @StateObject private var router = Router()
  @StateObject private var sheetManager = SheetManager()

  var content: (_ router: Router) -> Content

  var body: some View {
    NavigationStack(path: $router.path) {
      content(router)
        .navigationDestination(for: Screen.self) { screen in
          screen.view
        }
        .sheet(item: $sheetManager.sheet) { sheet in
          NavigationStack {
            sheet.view
              .environmentObject(sheetManager)
              .toast(isPresenting: $feedbackManager.show) {
                feedbackManager.toast
              }
          }
          .presentationDetents(sheet.detents)
          .presentationCornerRadius(sheet.cornerRadius)
          .presentationBackground(sheet.background)
          .presentationDragIndicator(.visible)
          .sheet(item: $sheetManager.nestedSheet, content: { nestedSheet in
            NavigationStack {
              nestedSheet.view
                .environmentObject(sheetManager)
                .toast(isPresenting: $feedbackManager.show) {
                  feedbackManager.toast
                }
            }
            .presentationDetents(nestedSheet.detents)
            .presentationCornerRadius(nestedSheet.cornerRadius)
            .presentationBackground(nestedSheet.background)
            .presentationDragIndicator(.visible)
          })
        }
        .onOpenURL { url in
          if let detailPage = url.detailPage {
            router.fetchAndNavigateTo(repository, detailPage, resetStack: true)
          }
        }
    }
    .toast(isPresenting: $feedbackManager.show) {
      feedbackManager.toast
    }
    .environmentObject(router)
    .environmentObject(sheetManager)
  }
}
