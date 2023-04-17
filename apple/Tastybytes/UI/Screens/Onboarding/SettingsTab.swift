import PhotosUI
import SwiftUI

struct ProfileSettingsTab: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @FocusState var focusedField: OnboardField?
  @State private var selectedItem: PhotosPickerItem?

  var body: some View {
    // swiftlint:disable accessibility_trait_for_button
    Form {
      Text("Configure your profile")
        .font(.title2)
        .fixedSize(horizontal: false, vertical: true)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)

      HStack {
        Spacer()
        PhotosPicker(
          selection: $selectedItem,
          matching: .images,
          photoLibrary: .shared()
        ) {
          AvatarView(avatarUrl: profileManager.getProfile().avatarUrl, size: 120, id: profileManager.getId())
        }
        .onChange(of: selectedItem) { newValue in
          guard let newValue else { return }
          Task { await profileManager.uploadAvatar(newAvatar: newValue, onError: { _ in
            feedbackManager.toggle(.error(.unexpected))
          }) }
        }
        Spacer()
      }.listRowBackground(Color.clear)

      Section {
        TextField("Username", text: $profileManager.username)
          .autocapitalization(.none)
          .disableAutocorrection(true)
          .focused($focusedField, equals: .username)
        TextField("First Name", text: $profileManager.firstName)
          .focused($focusedField, equals: .firstName)
        TextField("Last Name", text: $profileManager.lastName)
          .focused($focusedField, equals: .lastName)
      } header: {
        Text("Profile")
      } footer: {
        Text("These values are used in your personal page and can be seen by other users.")
      }
      .headerProminence(.increased)

      Section {
        Toggle("Use Name Instead of Username", isOn: .init(get: {
          profileManager.showFullName
        }, set: { newValue in
          profileManager.showFullName = newValue
          Task { await profileManager.updateDisplaySettings(onError: { _ in feedbackManager.toggle(.error(.unexpected)) }) }
        }))
      } footer: {
        Text("This only takes effect if both first name and last name are provided.")
      }

      Section {
        Toggle("Private Profile", isOn: .init(get: {
          profileManager.isPrivateProfile
        }, set: { newValue in
          profileManager.isPrivateProfile = newValue
          Task { await profileManager.updatePrivacySettings(onError: { _ in feedbackManager.toggle(.error(.unexpected)) }) }
        }))
      } header: {
        Text("Privacy")
      } footer: {
        Text("Private profile hides check-ins and profile page from everyone else but your friends")
      }
      // swiftlint:enable accessibility_trait_for_button
    }.onTapGesture {
      focusedField = nil
    }
  }
}
