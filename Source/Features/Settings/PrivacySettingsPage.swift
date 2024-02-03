import EnvironmentModels
import PhotosUI
import SwiftUI

@MainActor
struct PrivacySettingsScreen: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel

    var body: some View {
        Form {
            privacySection
        }
        .navigationTitle("settings.privacy.title")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var privacySection: some View {
        Section {
            Toggle("settings.privacy.privateProfile.label", isOn: .init(get: {
                profileEnvironmentModel.isPrivateProfile
            }, set: { newValue in
                profileEnvironmentModel.isPrivateProfile = newValue
                Task { await profileEnvironmentModel.updatePrivacySettings() }
            }))
        } header: {
            Text("profile.title")
        } footer: {
            Text("settings.privacy.privateProfile.description")
        }
        .headerProminence(.increased)
    }
}
