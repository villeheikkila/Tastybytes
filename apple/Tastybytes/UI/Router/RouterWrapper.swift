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
        .toast(isPresenting: $feedbackManager.show) {
          feedbackManager.toast
        }
        .sheet(item: $sheetManager.sheet) { sheet in
          NavigationStack {
            sheet.view
          }
          .presentationDetents(sheet.detents)
          .presentationCornerRadius(sheet.cornerRadius)
          .presentationBackground(sheet.background)
          .toast(isPresenting: $feedbackManager.show) {
            feedbackManager.toast
          }
          .sheet(item: $sheetManager.nestedSheet, content: { nestedSheet in
            NavigationStack {
              nestedSheet.view
            }
            .presentationDetents(nestedSheet.detents)
            .presentationCornerRadius(nestedSheet.cornerRadius)
            .presentationBackground(nestedSheet.background)
            .toast(isPresenting: $feedbackManager.show) {
              feedbackManager.toast
            }
          })
        }
        .onOpenURL { url in
          if let detailPage = url.detailPage {
            router.fetchAndNavigateTo(repository, detailPage, resetStack: true)
          }
        }
    }
    .environmentObject(router)
    .environmentObject(sheetManager)
  }
}
