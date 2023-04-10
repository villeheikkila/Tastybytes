import SwiftUI

struct SettingsScreen: View {
  @EnvironmentObject private var profileManager: ProfileManager

  var body: some View {
    List {
      Section {
        RouteLink(to: .profileSettings) {
          Label("Profile", systemImage: "person.crop.circle")
        }
        RouteLink(to: .accountSettings) {
          Label("Account", systemImage: "gear")
        }
        RouteLink(to: .applicationSettings) {
          Label("Application", systemImage: "app.badge.checkmark.fill")
        }
        RouteLink(to: .appIcon) {
          Label("App Icon", systemImage: "app.fill")
        }
        RouteLink(to: .blockedUsers) {
          Label("Blocked Users", systemImage: "person.fill.xmark")
        }
        RouteLink(to: .contributions) {
          Label("Contributions", systemImage: "plus.rectangle.fill.on.rectangle.fill")
        }
      }

      Section {
        RouteLink(to: .about) {
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
