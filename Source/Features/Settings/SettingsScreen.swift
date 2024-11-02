import Components

import Models
import SwiftUI

struct SettingsScreen: View {
    @Environment(AppModel.self) private var appModel
    @Environment(ProfileModel.self) private var profileModel

    var body: some View {
        List {
            Group {
                profileSection
                appSection
                aboutSection
                logOutSection
            }
            .customListRowBackground()
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .navigationBarTitle("settings.navigationTitle")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        if let subscriptionGroup = appModel.subscriptionGroup {
            ToolbarItemGroup(placement: .topBarTrailing) {
                RouterLink("subscription.callToAction  \(subscriptionGroup.name)", systemImage: "crown.fill", open: .sheet(.subscribe))
                    .labelStyle(.iconOnly)
                    .imageScale(.large)
                    .foregroundColor(.yellow)
            }
        }
    }

    @ViewBuilder private var profileSection: some View {
        Section {
            RouterLink("profile.title", systemName: "person.fill", color: .indigo, open: .screen(.profileSettings))
            RouterLink("account.navigationTitle", systemName: "gear", color: .gray, open: .screen(.accountSettings))
            RouterLink("settings.privacy.navigationTitle", systemName: "key.fill", color: .yellow, open: .screen(.privacySettings))
            RouterLink("blockedUsers.navigationTitle", systemName: "person.fill.xmark", color: .green, open: .screen(.blockedUsers))
        }
    }

    @ViewBuilder private var appSection: some View {
        Section {
            RouterLink(
                "notifications.title",
                systemName: "bell.badge.fill",
                color: .red,
                open: .screen(.notificationSettingsScreen)
            )
            RouterLink(open: .screen(.appIcon), label: {
                AppIconLabelRow()
            })
        }
    }

    @ViewBuilder private var aboutSection: some View {
        Section {
            RouterLink(
                "contributions.title",
                systemName: "plus",
                color: .teal,
                open: .screen(.contributions(profileModel.profile.id))
            )
            RouterLink("about.title", systemName: "at", color: .blue, open: .screen(.about))
        } footer: {
            if case .subscribed = profileModel.subscriptionStatus, let subscriptionName = appModel.subscriptionGroup?.name {
                HStack {
                    Spacer()
                    Text("subscription.thankYou \(appModel.infoPlist.appName) \(subscriptionName)")
                    Spacer()
                }
            }
        }
    }

    @ViewBuilder private var logOutSection: some View {
        Section {
            AsyncButton(action: {
                await profileModel.logOut()
            }, label: {
                HStack {
                    Spacer()
                    Text("settings.signOut")
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                    Spacer()
                }
            })
        }
    }
}

struct AppIconLabelRow: View {
    @Environment(ProfileModel.self) private var profileModel

    var body: some View {
        HStack {
            Image(profileModel.appIcon.icon)
                .resizable()
                .cornerRadius(8)
                .frame(width: 30, height: 30)
                .padding(.trailing, 8)
                .aspectRatio(contentMode: .fill)
                .accessibilityHidden(true)
            Text("settings.appIcon.title")
            Spacer()
            if profileModel.appIcon != .ramune {
                Text(profileModel.appIcon.label)
                    .foregroundColor(.secondary)
            }
        }
    }
}
