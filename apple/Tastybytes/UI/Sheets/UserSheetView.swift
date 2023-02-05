import SwiftUI

struct UserSheetView<Actions: View>: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var profileManager: ProfileManager
  @Environment(\.dismiss) private var dismiss

  let actions: (_ profile: Profile) -> Actions

  init(
    _ client: Client,
    actions: @escaping (_ profile: Profile) -> Actions
  ) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
    self.actions = actions
  }

  var body: some View {
    List {
      ForEach(viewModel.searchResults, id: \.id) { profile in
        HStack {
          AvatarView(avatarUrl: profile.getAvatarURL(), size: 32, id: profile.id)
          Text(profile.preferredName)
          Spacer()
          HStack {
            self.actions(profile)
          }
        }
      }
    }
    .navigationTitle("Search users")
    .navigationBarItems(trailing: Button(action: {
      dismiss()
    }) {
      Text("Cancel").bold()
    })
    .searchable(text: $viewModel.searchText)
    .onSubmit(of: .search) { viewModel.searchUsers(currentUserId: profileManager.getId()) }
  }
}

extension UserSheetView {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "UserSheetView")
    private let client: Client
    @Published var searchText: String = ""
    @Published var searchResults = [Profile]()

    init(_ client: Client) {
      self.client = client
    }

    func searchUsers(currentUserId: UUID) {
      Task {
        switch await client.profile.search(searchTerm: searchText, currentUserId: currentUserId) {
        case let .success(searchResults):
          withAnimation {
            self.searchResults = searchResults
          }
        case let .failure(error):
          logger
            .error(
              """
              sarching users by \(currentUserId) with search term \(self.searchText)\
               failed: \(error.localizedDescription)
              """
            )
        }
      }
    }
  }
}
