import Components
import EnvironmentModels
import SwiftUI

@MainActor
struct FlavorManagementScreen: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel

    var body: some View {
        List(appEnvironmentModel.flavors) { flavor in
            Text(flavor.label)
                .swipeActions {
                    ProgressButton("Delete", systemImage: "trash", role: .destructive, action: {
                        await appEnvironmentModel.deleteFlavor(flavor)
                    })
                }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitle("Flavors")
        .toolbar {
            toolbarContent
        }
        #if !targetEnvironment(macCatalyst)
        .refreshable {
            await appEnvironmentModel.refreshFlavors()
        }
        #endif
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            RouterLink("Add flavors", systemImage: "plus", sheet: .newFlavor(onSubmit: { newFlavor in
                await appEnvironmentModel.addFlavor(name: newFlavor)
            })).labelStyle(.iconOnly)
        }
    }
}
