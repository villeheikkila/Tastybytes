import SwiftUI

struct SettingsScreenView: View {
  let client: Client

  init(_ client: Client) {
    self.client = client
  }

  var body: some View {
    List {
      Section {
        NavigationLink(destination: ProfileSettingsScreenView(client)) {
          Label("Profile", systemImage: "person.crop.circle")
        }

        NavigationLink(destination: AccountSettingsScreenView(client)) {
          Label("Account", systemImage: "gear")
        }

        NavigationLink(destination: ApplicationSettingsScreenView(client)) {
          Label("Application", systemImage: "app.badge.checkmark.fill")
        }

        NavigationLink(destination: AppIconScreenView()) {
          Label("App Icon", systemImage: "app.fill")
        }

        NavigationLink(destination: BlockedUsersScreenView(client)) {
          Label("Blocked Users", systemImage: "person.fill.xmark")
        }

        NavigationLink(destination: ContributionsScreenView(client)) {
          Label("Contributions", systemImage: "plus.rectangle.fill.on.rectangle.fill")
        }
      }

      Section {
        NavigationLink(destination: AboutScreenView(client)) {
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
