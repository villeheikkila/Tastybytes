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
            ProgressButton("Delete", systemImage: "trash", role: .destructive, action: {
              await viewModel.deleteFlavor(flavor)
            })
          }
      }
    }
    .navigationBarTitle("Flavors")
    .navigationBarItems(
      trailing: RouterLink("Add flavors", systemImage: "plus", sheet: .newFlavor(onSubmit: { newFlavor in
        await viewModel.addFlavor(name: newFlavor)
      }))
      .labelStyle(.iconOnly)
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
