import SwiftUI

struct RouterWrapper<Content: View>: View {
  @EnvironmentObject private var repository: Repository
  @StateObject private var router = Router()

  var content: (_ router: Router) -> Content

  var body: some View {
    NavigationStack(path: $router.path) {
      content(router)
        .navigationDestination(for: Screen.self) { screen in
          screen.view
        }
        .sheet(item: $router.sheet) { sheet in
          NavigationStack {
            sheet.view
          }
          .presentationDetents(sheet.detents)
          .presentationCornerRadius(sheet.cornerRadius)
          .presentationBackground(sheet.background)
          .sheet(item: $router.nestedSheet, content: { nestedSheet in
            NavigationStack {
              nestedSheet.view
                .presentationDetents(nestedSheet.detents)
                .presentationCornerRadius(nestedSheet.cornerRadius)
                .presentationBackground(nestedSheet.background)
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
  }
}
