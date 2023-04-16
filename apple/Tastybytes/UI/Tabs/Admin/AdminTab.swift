import SwiftUI

struct AdminTab: View {
  @EnvironmentObject private var client: AppClient
  @Binding var resetNavigationOnTab: Tab?

  var body: some View {
    RouterWrapper { router in
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
