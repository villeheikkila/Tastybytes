import Components
import EnvironmentModels
import SwiftUI

@MainActor
struct FlavorManagementScreen: View {
    @Environment(AppDataEnvironmentModel.self) private var appDataEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel

    var body: some View {
        List(appDataEnvironmentModel.flavors) { flavor in
            Text(flavor.label)
                .swipeActions {
                    ProgressButton("Delete", systemImage: "trash", role: .destructive, action: {
                        await appDataEnvironmentModel.deleteFlavor(flavor)
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
            await appDataEnvironmentModel.refreshFlavors()
        }
        #endif
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            RouterLink("Add flavors", systemImage: "plus", sheet: .newFlavor(onSubmit: { newFlavor in
                await appDataEnvironmentModel.addFlavor(name: newFlavor)
            })).labelStyle(.iconOnly)
        }
    }
}
