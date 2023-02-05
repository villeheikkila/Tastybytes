import SwiftUI

struct PreferencesScreenView: View {
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
          Label("Application", systemImage: "gear")
        }

        NavigationLink(destination: AppIconScreenView()) {
          Label("App Icon", systemImage: "app.fill")
        }

        NavigationLink(destination: BlockedUsersScreenView(client)) {
          Label("Blocked Users", systemImage: "person.fill.xmark")
        }
      }

      Section {
        NavigationLink(destination: AboutScreenView(client)) {
          Label("About", systemImage: "info.circle")
        }
      }

      Section {
        Button(action: { Task {
          Task {
            await client.auth.logOut()
          }
        } }) {
          Label("Log Out", systemImage: "arrow.uturn.left")
            .fontWeight(.medium)
        }
      }
    }
    .navigationBarTitle("Preferences")
    .navigationBarTitleDisplayMode(.inline)
  }
}
