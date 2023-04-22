import SwiftUI

struct AdminTab: View {
  @Binding var resetNavigationOnTab: Tab?

  var body: some View {
    RouterWrapper { router in
      AdminScreen()
        .onChange(of: $resetNavigationOnTab.wrappedValue) { tab in
          if tab == .admin {
            router.reset()
            resetNavigationOnTab = nil
          }
        }
    }
  }
}
