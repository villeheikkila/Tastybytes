import SwiftUI

struct SettingsScreen: View {
  @EnvironmentObject private var profileManager: ProfileManager

  var body: some View {
    List {
      Section {
        RouterLink("Profile", systemImage: "person.crop.circle", screen: .profileSettings)
        RouterLink("Account", systemImage: "gear", screen: .accountSettings)
        RouterLink("Application", systemImage: "app.badge.checkmark.fill", screen: .applicationSettings)
        RouterLink("App Icon", systemImage: "app.fill", screen: .appIcon)
        RouterLink("Blocked Users", systemImage: "person.fill.xmark", screen: .blockedUsers)
        RouterLink("Contributions", systemImage: "plus.rectangle.fill.on.rectangle.fill", screen: .contributions)
      }

      Section {
        RouterLink("About", systemImage: "info.circle", screen: .about)
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
