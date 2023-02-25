import SwiftUI

struct AdminTab: View {
  let client: Client

  init(_ client: Client) {
    self.client = client
  }

  var body: some View {
    NavigationStack {
      List {
        NavigationLink(destination: FlavorManagementScreen(client)) {
          Label("Flavors", systemImage: "plus.rectangle.fill.on.rectangle.fill")
        }
        NavigationLink(destination: FlavorManagementScreen(client)) {
          Label("Products", systemImage: "plus.rectangle.fill.on.rectangle.fill")
        }
      }
      .navigationBarTitle("Admin")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}
