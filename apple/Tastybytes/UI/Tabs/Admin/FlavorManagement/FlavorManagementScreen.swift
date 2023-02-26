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
