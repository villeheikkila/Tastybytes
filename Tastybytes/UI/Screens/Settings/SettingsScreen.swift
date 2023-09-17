import EnvironmentModels
import Models
import SwiftUI

struct SettingsScreen: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel

    var body: some View {
        List {
            settingsSection
            aboutSection
            logOutSection
        }
        .listStyle(.insetGrouped)
        .navigationBarTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            RouterLink("Subscribe to Premium", systemImage: "crown.fill", sheet: .subscribe)
                .labelStyle(.iconOnly)
                .imageScale(.large)
                .foregroundColor(.yellow)
        }
    }

    @ViewBuilder private var settingsSection: some View {
        Section {
            RouterLink("Profile", systemName: "person.fill", color: .indigo, screen: .profileSettings)
            RouterLink("Account", systemName: "gear", color: .gray, screen: .accountSettings)
            RouterLink("Privacy", systemName: "key.fill", color: .yellow, screen: .privacySettings)
            RouterLink("Appearance", systemName: "paintbrush.fill", color: .blue, screen: .appearanaceSettings)
            RouterLink(
                "Notifications",
                systemName: "bell.badge.fill",
                color: .red,
                screen: .notificationSettingsScreen
            )
            RouterLink(screen: .appIcon, label: {
                AppIconLabelRow()
            })
            RouterLink("Blocked Users", systemName: "person.fill.xmark", color: .green, screen: .blockedUsers)
        }
    }

    @ViewBuilder private var aboutSection: some View {
        Section {
            RouterLink(
                "Your Contributions",
                systemName: "plus",
                color: .teal,
                screen: .contributions
            )
            RouterLink("About", systemName: "at", color: .blue, screen: .about)
        } footer: {
            if profileEnvironmentModel.hasRole(.pro) {
                HStack {
                    Spacer()
                    Text("You have \(Config.appName) Pro. Thank you!")
                    Spacer()
                }
            }
        }
    }

    @ViewBuilder private var logOutSection: some View {
        Section {
            ProgressButton(action: {
                await profileEnvironmentModel.logOut()
            }, label: {
                Spacer()
                Text("Sign Out")
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                Spacer()
            })
        }
    }
}

struct AppIconLabelRow: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel

    var body: some View {
        HStack {
            Image(profileEnvironmentModel.appIcon.icon)
                .resizable()
                .cornerRadius(8)
                .frame(width: 30, height: 30)
                .padding(.trailing, 8)
                .aspectRatio(contentMode: .fill)
                .accessibilityHidden(true)
            Text("App Icon")
            Spacer()
            if profileEnvironmentModel.appIcon != .ramune {
                Text(profileEnvironmentModel.appIcon.label)
                    .foregroundColor(.secondary)
            }
        }
    }
}
