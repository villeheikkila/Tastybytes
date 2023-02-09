import SwiftUI

struct ProfileSettingsTabView: View {
  @StateObject private var viewModel: ViewModel

  init(_ client: Client) {
    _viewModel = StateObject(wrappedValue: ViewModel(client: client))
  }

  var body: some View {
    VStack {
      if let profile = viewModel.profile {
        AvatarView(avatarUrl: profile.avatarUrl, size: 90, id: profile.id)

        Text("hei")
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

    init(client: Client) {
      self.client = client
    }

    func loadProfile() {
      Task {
        switch await client.profile.getCurrentUser() {
        case let .success(profile):
          self.profile = profile
        case let .failure(error):
          logger.error("failed to load profile: \(error.localizedDescription)")
        }
      }
    }
  }
}
