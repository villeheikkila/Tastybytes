import Components
import EnvironmentModels
import Models
import SwiftUI

struct FlavorsAdminScreen: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @State private var searchTerm = ""

    private var filtered: [Flavor.Saved] {
        appEnvironmentModel.flavors.filteredBySearchTerm(by: \.name, searchTerm: searchTerm)
    }

    var body: some View {
        List(filtered) { flavor in
            FlavorEntityView(flavor: flavor)
                .swipeActions {
                    AsyncButton("labels.delete", systemImage: "trash", role: .destructive, action: {
                        await appEnvironmentModel.deleteFlavor(flavor)
                    })
                }
        }
        .listStyle(.plain)
        .searchable(text: $searchTerm)
        .refreshable {
            await appEnvironmentModel.refreshFlavors()
        }
        .navigationBarTitle("flavor.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            RouterLink("flavor.add.labels", systemImage: "plus", open: .sheet(.newFlavor(onSubmit: { newFlavor in
                await appEnvironmentModel.addFlavor(name: newFlavor)
            }))).labelStyle(.iconOnly)
        }
    }
}
