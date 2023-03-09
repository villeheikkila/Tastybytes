import SwiftUI

struct AdminTab: View {
  @StateObject private var router = Router()
  @Binding private var resetNavigationOnTab: Tab?

  let client: Client

  init(_ client: Client, resetNavigationOnTab: Binding<Tab?>) {
    self.client = client
    _resetNavigationOnTab = resetNavigationOnTab
  }

  var body: some View {
    NavigationStack(path: $router.path) {
      List {
        NavigationLink(value: Route.categoryManagement) {
          Label("Categories", systemImage: "plus.rectangle.fill.on.rectangle.fill")
        }
        NavigationLink(value: Route.flavorManagementScreen) {
          Label("Flavors", systemImage: "plus.rectangle.fill.on.rectangle.fill")
        }
        NavigationLink(value: Route.verificationScreen) {
          Label("Verification", systemImage: "plus.rectangle.fill.on.rectangle.fill")
        }
        NavigationLink(value: Route.duplicateProducts) {
          Label("Duplicates", systemImage: "plus.rectangle.fill.on.rectangle.fill")
        }
      }
      .withRoutes(client)
      .navigationBarTitle("Admin")
      .navigationBarTitleDisplayMode(.inline)
    }
    .onChange(of: $resetNavigationOnTab.wrappedValue) { tab in
      if tab == .admin {
        router.reset()
        resetNavigationOnTab = nil
      }
    }
    .onOpenURL { url in
      if let detailPage = url.detailPage {
        router.fetchAndNavigateTo(client, detailPage, resetStack: true)
      }
    }
    .environmentObject(router)
  }
}
