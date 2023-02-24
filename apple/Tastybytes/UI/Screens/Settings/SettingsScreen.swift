import SwiftUI

struct SettingsScreen: View {
  let client: Client

  init(_ client: Client) {
    self.client = client
  }

  var body: some View {
    List {
      Section {
        NavigationLink(destination: ProfileSettingsScreen(client)) {
          Label("Profile", systemImage: "person.crop.circle")
        }

        NavigationLink(destination: AccountSettingsScreen(client)) {
          Label("Account", systemImage: "gear")
        }

        NavigationLink(destination: ApplicationSettingsScreen(client)) {
          Label("Application", systemImage: "app.badge.checkmark.fill")
        }

        NavigationLink(destination: AppIconScreen()) {
          Label("App Icon", systemImage: "app.fill")
        }

        NavigationLink(destination: BlockedUsersScreen(client)) {
          Label("Blocked Users", systemImage: "person.fill.xmark")
        }

        NavigationLink(destination: ContributionsScreen(client)) {
          Label("Contributions", systemImage: "plus.rectangle.fill.on.rectangle.fill")
        }
      }

      Section {
        NavigationLink(destination: AboutScreen(client)) {
          Label("About", systemImage: "info.circle")
        }
      }

      Section {
        Button(action: logOut) {
          Label("Log Out", systemImage: "arrow.uturn.left")
            .fontWeight(.medium)
        }
      }
    }
    .navigationBarTitle("Preferences")
    .navigationBarTitleDisplayMode(.inline)
  }

  func logOut() {
    Task { await client.auth.logOut() }
  }
}
