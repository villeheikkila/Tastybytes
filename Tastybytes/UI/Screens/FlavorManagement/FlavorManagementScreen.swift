import SwiftUI

struct FlavorManagementScreen: View {
    @Environment(AppDataEnvironmentModel.self) private var appDataEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel

    var body: some View {
        List {
            ForEach(appDataEnvironmentModel.flavors) { flavor in
                Text(flavor.label)
                    .swipeActions {
                        ProgressButton("Delete", systemSymbol: .trash, role: .destructive, action: {
                            await appDataEnvironmentModel.deleteFlavor(flavor)
                        })
                    }
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
            RouterLink("Add flavors", systemSymbol: .plus, sheet: .newFlavor(onSubmit: { newFlavor in
                await appDataEnvironmentModel.addFlavor(name: newFlavor)
            })).labelStyle(.iconOnly)
        }
    }
}
