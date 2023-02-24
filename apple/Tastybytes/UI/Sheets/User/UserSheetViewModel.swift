import SwiftUI

extension UserSheet {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "UserSheet")
    let client: Client
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
