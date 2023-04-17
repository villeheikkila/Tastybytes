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
            ProgressButton("Delete", systemImage: "trash", role: .destructive, action: {
              await appDataManager.deleteFlavor(flavor)
            })
          }
      }
    }
    .navigationBarTitle("Flavors")
    .navigationBarItems(
      trailing: RouterLink("Add flavors", systemImage: "plus", sheet: .newFlavor(onSubmit: { newFlavor in
        await appDataManager.addFlavor(name: newFlavor)
      })).labelStyle(.iconOnly)
    )
    .refreshable {
      await feedbackManager.wrapWithHaptics {
        await appDataManager.loadFlavors()
      }
    }
    .task {
      await appDataManager.loadFlavors()
    }
  }
}
