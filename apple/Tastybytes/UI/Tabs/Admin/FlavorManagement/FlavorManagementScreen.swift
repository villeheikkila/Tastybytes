import SwiftUI

struct FlavorManagementScreen: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var hapticManager: HapticManager
  @EnvironmentObject private var router: Router

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
    .navigationBarItems(
      trailing: Button(role: .destructive, action: { router.openSheet(.newFlavor(onSubmit: { newFlavor in
        viewModel.addFlavor(name: newFlavor)
      })) }, label: {
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
