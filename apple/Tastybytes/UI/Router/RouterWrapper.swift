import SwiftUI

struct RouterWrapper<Content: View>: View {
  @StateObject private var router = Router()
  let client: Client
  var content: (_ router: Router) -> Content

  init(_ client: Client, @ViewBuilder content: @escaping (_ router: Router) -> Content) {
    self.client = client
    self.content = content
  }

  var body: some View {
    NavigationStack(path: $router.path) {
      content(router)
        .navigationDestination(for: Screen.self) { screen in
          screen.view(client)
        }
        .sheet(item: $router.sheet) { sheet in
          NavigationStack {
            sheet.view(client)
          }
          .presentationDetents(sheet.detents)
          .presentationCornerRadius(sheet.cornerRadius)
          .presentationBackground(sheet.background)
          .sheet(item: $router.nestedSheet, content: { nestedSheet in
            NavigationStack {
              nestedSheet.view(client)
                .presentationDetents(nestedSheet.detents)
                .presentationCornerRadius(nestedSheet.cornerRadius)
                .presentationBackground(nestedSheet.background)
            }
          })
        }
        .onOpenURL { url in
          if let detailPage = url.detailPage {
            router.fetchAndNavigateTo(client, detailPage, resetStack: true)
          }
        }
    }
    .environmentObject(router)
  }
}
