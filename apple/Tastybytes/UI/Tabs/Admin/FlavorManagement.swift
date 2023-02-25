import SwiftUI

struct FlavorManagementScreen: View {
  @StateObject private var viewModel: ViewModel

  init(_ client: Client) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
  }

  var body: some View {
    List {
      ForEach(viewModel.flavors) { flavor in
        Text(flavor.label).swipeActions {
          Button(role: .destructive, action: {
            viewModel.deleteFlavor(flavor)
          }, label: {
            Label("Delete", systemImage: "trash")
          })
        }
      }
    }
    .navigationBarTitle("Flavors")
    .refreshable {
      await viewModel.loadFlavors()
    }
    .task {
      await viewModel.loadFlavors()
    }
  }
}

extension FlavorManagementScreen {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "FlavorManagementView")
    let client: Client
    @Published var flavors = [Flavor]()

    init(_ client: Client) {
      self.client = client
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
