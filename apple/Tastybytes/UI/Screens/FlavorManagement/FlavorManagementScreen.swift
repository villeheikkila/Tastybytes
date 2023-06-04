import SwiftUI

struct FlavorManagementScreen: View {
  @EnvironmentObject private var appDataManager: AppDataManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @EnvironmentObject private var router: Router

  var body: some View {
    List {
      ForEach(appDataManager.flavors) { flavor in
        Text(flavor.label)
          .swipeActions {
            ProgressButton("Delete", systemSymbol: .trash, role: .destructive, action: {
              await appDataManager.deleteFlavor(flavor)
            })
          }
      }
    }
    .listStyle(.insetGrouped)
    .navigationBarTitle("Flavors")
    .navigationBarItems(
      trailing: RouterLink("Add flavors", systemSymbol: .plus, sheet: .newFlavor(onSubmit: { newFlavor in
        await appDataManager.addFlavor(name: newFlavor)
      })).labelStyle(.iconOnly)
    )
    #if !targetEnvironment(macCatalyst)
    .refreshable {
      await appDataManager.refreshFlavors()
    }
    #endif
  }
}
