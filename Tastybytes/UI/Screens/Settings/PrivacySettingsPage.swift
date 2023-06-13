import PhotosUI
import SwiftUI

struct PrivacySettingsScreen: View {
    @Environment(ProfileManager.self) private var profileManager
    @Environment(FeedbackManager.self) private var feedbackManager

    var body: some View {
        Form {
            privacySection
        }
        .navigationTitle("Privacy")
    }

    private var privacySection: some View {
        Section {
            Toggle("Private Profile", isOn: .init(get: {
                profileManager.isPrivateProfile
            }, set: { newValue in
                profileManager.isPrivateProfile = newValue
                Task { await profileManager.updatePrivacySettings() }
            }))
        } header: {
            Text("Profile")
        } footer: {
            Text("Private profile hides check-ins and profile page from everyone else but your friends")
        }
        .headerProminence(.increased)
    }
}
