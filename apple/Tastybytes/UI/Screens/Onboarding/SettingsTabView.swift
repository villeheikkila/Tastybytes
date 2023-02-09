import PhotosUI
import SwiftUI

struct ProfileSettingsTabView: View {
  @EnvironmentObject private var viewModel: OnboardingViewModel

  var body: some View {
    Form {
      Text("Configure your profile")
        .font(.title2)
        .fixedSize(horizontal: false, vertical: true)

        .listRowBackground(Color.clear)
      if let profile = viewModel.profile {
        HStack {
          Spacer()
          PhotosPicker(
            selection: $viewModel.selectedItem,
            matching: .images,
            photoLibrary: .shared()
          ) {
            AvatarView(avatarUrl: viewModel.avatarFileName, size: 120, id: profile.id)
          }
          .onChange(of: viewModel.selectedItem) { newValue in
            viewModel.uploadAvatar(userId: profile.id, newAvatar: newValue)
          }
          Spacer()
        }.listRowBackground(Color.clear)

        Section {
          TextField("Username", text: $viewModel.username)
            .autocapitalization(.none)
            .disableAutocorrection(true)
          TextField("First Name", text: $viewModel.firstName)
          TextField("Last Name", text: $viewModel.lastName)
        } header: {
          Text("Profile")
        } footer: {
          Text("These values are used in your personal page and can be seen by other users.")
        }
        .headerProminence(.increased)

        Section {
          Toggle("Use Name Instead of Username", isOn: $viewModel.showFullName)
        } footer: {
          Text("This only takes effect if both first name and last name are provided.")
        }

        Section {
          Toggle("Private Profile", isOn: $viewModel.isPrivateProfile)
        } header: {
          Text("Privacy")
        } footer: {
          Text("Private profile hides check-ins and profile page from everyone else but your friends")
        }
      }
    }
    .task {
      viewModel.loadProfile()
    }
  }
}
