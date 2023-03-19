import SwiftUI

struct FlavorManagementScreen: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var hapticManager: HapticManager

  init(_ client: Client) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
  }

  var body: some View {
    List {
      ForEach(viewModel.flavors) { flavor in
        Text(flavor.label)
          .swipeActions {
            Button(role: .destructive, action: {
              viewModel.deleteFlavor(flavor)
            }, label: {
              Label("Delete", systemImage: "trash")
            })
          }
      }
    }
    .navigationBarTitle("Flavors")
    .sheet(isPresented: $viewModel.showAddFlavor, content: {
      NavigationStack {
        DismissableSheet(title: "Add Flavor") {
          Form {
            TextField("Name", text: $viewModel.newFlavorName)
            Button(action: { viewModel.addFlavor() }, label: {
              Text("Add")
            })
          }
        }
      }.presentationDetents([.medium])
    })
    .navigationBarItems(
      trailing: Button(role: .destructive, action: { viewModel.showAddFlavor = true }, label: {
        Label("Add flavors", systemImage: "plus")
          .labelStyle(.iconOnly)
      })
    )
    .refreshable {
      await hapticManager.wrapWithHaptics {
        await viewModel.loadFlavors()
      }
    }
    .task {
      await viewModel.loadFlavors()
    }
  }
}
