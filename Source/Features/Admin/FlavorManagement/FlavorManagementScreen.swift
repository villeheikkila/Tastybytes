import Components
import EnvironmentModels
import SwiftUI

struct FlavorManagementScreen: View {
    @Environment(Router.self) private var router
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel

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
            Button("flavor.add.labels", systemImage: "plus", action: { router.openRootSheet(.newFlavor(onSubmit: { newFlavor in
                await appEnvironmentModel.addFlavor(name: newFlavor)
            })) }).labelStyle(.iconOnly)
        }
    }
}
