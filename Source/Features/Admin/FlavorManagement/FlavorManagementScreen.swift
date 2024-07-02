import Components
import EnvironmentModels
import SwiftUI

struct FlavorManagementScreen: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel

    var body: some View {
        List(appEnvironmentModel.flavors) { flavor in
            Text(flavor.label)
                .swipeActions {
                    ProgressButton("labels.delete", systemImage: "trash", role: .destructive, action: {
                        await appEnvironmentModel.deleteFlavor(flavor)
                    })
                }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await appEnvironmentModel.refreshFlavors()
        }
        .navigationBarTitle("flavor.navigationTitle")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            RouterLink("flavor.add.labels", systemImage: "plus", sheet: .newFlavor(onSubmit: { newFlavor in
                await appEnvironmentModel.addFlavor(name: newFlavor)
            })).labelStyle(.iconOnly)
        }
    }
}
