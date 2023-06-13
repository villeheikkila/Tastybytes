import SwiftUI

struct SettingsScreen: View {
    @Environment(ProfileManager.self) private var profileManager

    var body: some View {
        List {
            Section {
                RouterLink("Profile", systemSymbol: .personCropCircle, color: .indigo, screen: .profileSettings)
                RouterLink("Account", systemSymbol: .gear, color: .gray, screen: .accountSettings)
                RouterLink("Privacy", systemSymbol: .keyFill, color: .yellow, screen: .privacySettings)
                RouterLink("Appearance", systemSymbol: .paintbrushFill, color: .blue, screen: .appearanaceSettings)
                RouterLink(
                    "Notifications",
                    systemSymbol: .bellBadgeFill,
                    color: .red,
                    screen: .notificationSettingsScreen
                )
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
                RouterLink("Blocked Users", systemSymbol: .personFillXmark, color: .green, screen: .blockedUsers)
            }

            Section {
                RouterLink(
                    "Your Contributions",
                    systemSymbol: .plusRectangleFillOnRectangleFill,
                    color: .teal,
                    screen: .contributions
                )
                RouterLink("About", systemSymbol: .at, color: .blue, screen: .about)
            }

            Section {
                ProgressButton(action: {
                    await profileManager.logOut()
                }, label: {
                    Spacer()
                    Text("Sign Out")
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                    Spacer()
                })
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
