import SwiftUI

struct SettingsScreen: View {
  @EnvironmentObject private var profileManager: ProfileManager

  var body: some View {
    List {
      Section {
        RouterLink("Profile", systemImage: "person.crop.circle", color: .indigo, screen: .profileSettings)
        RouterLink("Account", systemImage: "gear", color: .gray, screen: .accountSettings)
        RouterLink("Appearance", systemImage: "paintbrush.fill", color: .blue, screen: .appearanaceSettings)
        RouterLink("Notifications", systemImage: "bell.badge.fill", color: .red, screen: .notificationSettingsScreen)
        RouterLink(screen: .appIcon) {
          HStack {
            Image(profileManager.appIcon.icon)
              .resizable()
              .cornerRadius(8)
              .frame(width: 30, height: 30)
              .padding(.trailing, 8)
              .aspectRatio(contentMode: .fill)
              .accessibilityHidden(true)
            Text("App Icon")
          }
        }
        RouterLink("Blocked Users", systemImage: "person.fill.xmark", color: .green, screen: .blockedUsers)
      }

      Section {
        RouterLink(
          "Your Contributions",
          systemImage: "plus.rectangle.fill.on.rectangle.fill",
          color: .teal,
          screen: .contributions
        )
        RouterLink("About", systemImage: "at", color: .blue, screen: .about)
      }

      Section {
        ProgressButton(action: {
          await profileManager.logOut()
        }) {
          Spacer()
          Text("Sign Out")
            .fontWeight(.medium)
            .foregroundColor(.red)
          Spacer()
        }
      }
    }
    .navigationBarTitle("Preferences")
    .navigationBarTitleDisplayMode(.inline)
  }
}
