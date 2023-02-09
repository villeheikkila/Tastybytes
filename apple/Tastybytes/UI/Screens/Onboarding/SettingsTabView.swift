import PhotosUI
import SwiftUI

struct ProfileSettingsTabView: View {
  @StateObject private var viewModel: ViewModel

  init(_ client: Client) {
    _viewModel = StateObject(wrappedValue: ViewModel(client: client))
  }

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

extension ProfileSettingsTabView {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ProfileSettingsTabView")
    let client: Client
    @Published var profile: Profile.Extended?
    @Published var selectedItem: PhotosPickerItem?
    @Published var username = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var showFullName = false
    @Published var isPrivateProfile = false
    @Published var avatarFileName: String?

    init(client: Client) {
      self.client = client
    }

    func loadProfile() {
      Task {
        switch await client.profile.getCurrentUser() {
        case let .success(profile):
          self.profile = profile
          username = profile.username
          lastName = profile.lastName.orEmpty
          firstName = profile.firstName.orEmpty
          showFullName = profile.nameDisplay == Profile.NameDisplay.fullName
          isPrivateProfile = profile.isPrivate
          avatarFileName = profile.avatarUrl
        case let .failure(error):
          logger.error("failed to load profile: \(error.localizedDescription)")
        }
      }
    }

    func updateProfile(onSuccess: @escaping () -> Void) {
      let update = Profile.UpdateRequest(
        username: username,
        firstName: firstName,
        lastName: lastName,
        isPrivate: isPrivateProfile,
        showFullName: showFullName
      )

      Task {
        switch await client.profile.update(
          update: update
        ) {
        case .success:
          onSuccess()
        case let .failure(error):
          logger.warning("failed to update profile: \(error.localizedDescription)")
        }
      }
    }

    func uploadAvatar(userId: UUID, newAvatar: PhotosPickerItem?) {
      Task {
        if let imageData = try await newAvatar?.loadTransferable(type: Data.self),
           let image = UIImage(data: imageData),
           let data = image.jpegData(compressionQuality: 0.1)
        {
          switch await client.profile.uploadAvatar(userId: userId, data: data) {
          case let .success(fileName):
            self.avatarFileName = fileName
          case let .failure(error):
            logger
              .error(
                "uplodaing avatar for \(userId) failed: \(error.localizedDescription)"
              )
          }
        }
      }
    }
  }
}
