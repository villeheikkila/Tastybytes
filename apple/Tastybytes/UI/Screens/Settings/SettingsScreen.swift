import SwiftUI

struct SettingsScreen: View {
  @EnvironmentObject private var profileManager: ProfileManager

  var body: some View {
    List {
      Section {
        RouterLink(screen: .profileSettings) {
          Label("Profile", systemImage: "person.crop.circle")
        }
        RouterLink(screen: .accountSettings) {
          Label("Account", systemImage: "gear")
        }
        RouterLink(screen: .applicationSettings) {
          Label("Application", systemImage: "app.badge.checkmark.fill")
        }
        RouterLink(screen: .appIcon) {
          Label("App Icon", systemImage: "app.fill")
        }
        RouterLink(screen: .blockedUsers) {
          Label("Blocked Users", systemImage: "person.fill.xmark")
        }
        RouterLink(screen: .contributions) {
          Label("Contributions", systemImage: "plus.rectangle.fill.on.rectangle.fill")
        }
      }

      Section {
        RouterLink(screen: .about) {
          Label("About", systemImage: "info.circle")
        }
      }

      Section {
        ProgressButton(action: {
          await profileManager.logOut()
        }, label: {
          Label("Log Out", systemImage: "arrow.uturn.left")
            .fontWeight(.medium)
        })
      }
    }
    .navigationBarTitle("Preferences")
    .navigationBarTitleDisplayMode(.inline)
  }
}
