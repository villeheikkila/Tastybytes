import SwiftUI

extension FlavorManagementScreen {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "FlavorManagementView")
    let client: Client
    @Published var flavors = [Flavor]()
    @Published var showAddFlavor = false
    @Published var newFlavorName = ""
    init(_ client: Client) {
      self.client = client
    }

    func addFlavor() {
      Task {
        switch await client.flavor.insert(newFlavor: Flavor.NewRequest(name: newFlavorName)) {
        case let .success(newFlavor):
          withAnimation {
            flavors.append(newFlavor)
            newFlavorName = ""
            showAddFlavor = false
          }
        case let .failure(error):
          logger
            .error(
              "failed to delete flavor: \(error.localizedDescription)"
            )
        }
      }
    }

    func deleteFlavor(_ flavor: Flavor) {
      Task {
        switch await client.flavor.delete(id: flavor.id) {
        case .success:
          withAnimation {
            flavors.remove(object: flavor)
          }
        case let .failure(error):
          logger
            .error(
              "failed to delete flavor: \(error.localizedDescription)"
            )
        }
      }
    }

    func loadFlavors() async {
      switch await client.flavor.getAll() {
      case let .success(flavors):
        withAnimation {
          self.flavors = flavors
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
