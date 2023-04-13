import SwiftUI

struct AdminTab: View {
  @Binding private var resetNavigationOnTab: Tab?

  let client: Client

  init(_ client: Client, resetNavigationOnTab: Binding<Tab?>) {
    self.client = client
    _resetNavigationOnTab = resetNavigationOnTab
  }

  var body: some View {
    RouterWrapper(client) { router in
      List {
        RouterLink("Categories", systemImage: "plus.rectangle.fill.on.rectangle.fill", screen: .categoryManagement)
        RouterLink("Flavors", systemImage: "plus.rectangle.fill.on.rectangle.fill", screen: .flavorManagement)
        RouterLink("Verification", systemImage: "plus.rectangle.fill.on.rectangle.fill", screen: .verification)
        RouterLink("Duplicates", systemImage: "plus.rectangle.fill.on.rectangle.fill", screen: .duplicateProducts)
      }
      .navigationBarTitle("Admin")
      .navigationBarTitleDisplayMode(.inline)
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
    }
  }
}
