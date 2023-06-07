import SwiftUI

struct RouterWrapper<Content: View>: View {
  @Environment(Repository.self) private var repository
  @Environment(FeedbackManager.self) private var feedbackManager
  @State private var router: Router
  @State private var sheetManager = SheetManager()

  let content: (_ router: Router) -> Content

  init(tab: Tab, content: @escaping (_ router: Router) -> Content) {
    _router = State(wrappedValue: Router(tab: tab))
    self.content = content
  }

  var body: some View {
    @Bindable var feedbackManager = feedbackManager
    @Bindable var router = router
    NavigationStack(path: $router.path) {
      content(router)
        .navigationDestination(for: Screen.self) { screen in
          screen.view
        }
        .sheet(item: $sheetManager.sheet) { sheet in
          NavigationStack {
            sheet.view
              .environment(sheetManager)
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
                .environment(sheetManager)
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
    .environment(router)
    .environment(sheetManager)
    .onChange(of: router.path) {
        router.storeState()
    }
  }
}
