import SwiftUI

extension FlavorSheet {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "FlavorSheet")
    let client: Client
    @Published var availableFlavors = [Flavor]()
    @Published var searchTerm = ""

    let maxFlavors = 4

    init(_ client: Client) {
      self.client = client
    }

    var filteredFlavors: [Flavor] {
      if searchTerm.isEmpty {
        return availableFlavors
      } else {
        return availableFlavors.filter { $0.name.lowercased().contains(searchTerm.lowercased()) }
      }
    }

    func loadFlavors() {
      guard availableFlavors.isEmpty else { return }
      Task {
        switch await client.flavor.getAll() {
        case let .success(flavors):
          withAnimation {
            self.availableFlavors = flavors
          }
        case let .failure(error):
          logger
            .error(
              "fetching flavors failed: \(error.localizedDescription)"
            )
        }
      }
    }
  }
}
