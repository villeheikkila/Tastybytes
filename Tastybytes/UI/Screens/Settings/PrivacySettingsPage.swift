import EnvironmentModels
import PhotosUI
import SwiftUI

struct PrivacySettingsScreen: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel

    var body: some View {
        Form {
            privacySection
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var privacySection: some View {
        Section {
            Toggle("Private Profile", isOn: .init(get: {
                profileEnvironmentModel.isPrivateProfile
            }, set: { newValue in
                profileEnvironmentModel.isPrivateProfile = newValue
                Task { await profileEnvironmentModel.updatePrivacySettings() }
            }))
        } header: {
            Text("Profile")
        } footer: {
            Text("Private profile hides check-ins and profile page from everyone else but your friends")
        }
        .headerProminence(.increased)
    }
}
