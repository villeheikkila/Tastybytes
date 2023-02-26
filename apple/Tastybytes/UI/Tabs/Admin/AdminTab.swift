import SwiftUI

struct AdminTab: View {
  @StateObject private var router = Router()

  let client: Client

  init(_ client: Client) {
    self.client = client
  }

  var body: some View {
    NavigationStack(path: $router.path) {
      List {
        NavigationLink(destination: FlavorManagementScreen(client)) {
          Label("Flavors", systemImage: "plus.rectangle.fill.on.rectangle.fill")
        }
        NavigationLink(destination: ProductVerificationScreen(client)) {
          Label("Products", systemImage: "plus.rectangle.fill.on.rectangle.fill")
        }
      }
      .withRoutes(client)
      .navigationBarTitle("Admin")
      .navigationBarTitleDisplayMode(.inline)
    }
    .onOpenURL { url in
      if let detailPage = url.detailPage {
        router.fetchAndNavigateTo(client, detailPage, resetStack: true)
      }
    }
    .environmentObject(router)
  }
}
