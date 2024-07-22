import EnvironmentModels
import SwiftUI

struct ProfileInfoSettingSectionsView: View {
    enum FocusField {
        case username, firstName, lastName
    }

    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel

    @FocusState var focusedField: FocusField?
    @Binding var usernameIsAvailable: Bool
    @Binding var username: String
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var isLoading: Bool

    var body: some View {
        requiredSection
        additionalInformationSection
    }

    private var requiredSection: some View {
        Section {
            TextField("profile.username.placeholder", text: $username)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .focused($focusedField, equals: .username)
        } header: {
            Text("settings.profile.username")
        } footer: {
            Text("settings.profile.username.description")
        }
        .headerProminence(.increased)
        .task {
            username = profileEnvironmentModel.username
            firstName = profileEnvironmentModel.firstName ?? ""
            lastName = profileEnvironmentModel.lastName ?? ""
            usernameIsAvailable = await profileEnvironmentModel.checkIfUsernameIsAvailable(username: username)
        }
        .onChange(of: username) {
            usernameIsAvailable = false
            isLoading = true
        }
        .task(id: username, milliseconds: 300) {
            guard username.count >= 3 else { return }
            let isAvailable = await profileEnvironmentModel
                .checkIfUsernameIsAvailable(username: username)
            withAnimation {
                usernameIsAvailable = isAvailable
                isLoading = false
            }
        }
    }

    private var additionalInformationSection: some View {
        Section {
            TextField("settings.profile.firstName", text: $firstName)
                .focused($focusedField, equals: .firstName)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
            TextField("settings.profile.lastName", text: $lastName)
                .focused($focusedField, equals: .lastName)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
        } header: {
            Text("profile.additionalInformation.header")
        } footer: {
            Text("profile.additionalInformation.footer")
        }
        .headerProminence(.increased)
    }
}
