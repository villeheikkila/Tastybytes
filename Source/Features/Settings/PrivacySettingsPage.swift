
import PhotosUI
import SwiftUI

struct PrivacySettingsScreen: View {
    @Environment(ProfileModel.self) private var profileModel

    var body: some View {
        Form {
            privacySection
        }
        .navigationTitle("settings.privacy.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var privacySection: some View {
        Section {
            Toggle("settings.privacy.privateProfile.label", isOn: .init(get: {
                profileModel.isPrivateProfile
            }, set: { newValue in
                Task { await profileModel.updatePrivacySettings(isPrivate: newValue) }
            }))
        } footer: {
            Text("settings.privacy.privateProfile.description")
        }
        .headerProminence(.increased)
    }
}
