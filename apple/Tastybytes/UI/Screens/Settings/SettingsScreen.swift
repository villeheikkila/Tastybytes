import SwiftUI

struct SettingsScreen: View {
  @EnvironmentObject private var profileManager: ProfileManager

  var body: some View {
    List {
      Section {
        RouteLink(screen: .profileSettings) {
          Label("Profile", systemImage: "person.crop.circle")
        }
        RouteLink(screen: .accountSettings) {
          Label("Account", systemImage: "gear")
        }
        RouteLink(screen: .applicationSettings) {
          Label("Application", systemImage: "app.badge.checkmark.fill")
        }
        RouteLink(screen: .appIcon) {
          Label("App Icon", systemImage: "app.fill")
        }
        RouteLink(screen: .blockedUsers) {
          Label("Blocked Users", systemImage: "person.fill.xmark")
        }
        RouteLink(screen: .contributions) {
          Label("Contributions", systemImage: "plus.rectangle.fill.on.rectangle.fill")
        }
      }

      Section {
        RouteLink(screen: .about) {
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
