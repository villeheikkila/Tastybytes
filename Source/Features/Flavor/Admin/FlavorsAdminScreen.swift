import Components

import Models
import SwiftUI

struct FlavorsAdminScreen: View {
    @Environment(AppModel.self) private var appModel
    @State private var searchTerm = ""

    private var filtered: [Flavor.Saved] {
        appModel.flavors.filteredBySearchTerm(by: \.name, searchTerm: searchTerm)
    }

    var body: some View {
        List(filtered) { flavor in
            FlavorView(flavor: flavor)
                .swipeActions {
                    AsyncButton("labels.delete", systemImage: "trash", role: .destructive, action: {
                        await appModel.deleteFlavor(flavor)
                    })
                }
        }
        .listStyle(.plain)
        .searchable(text: $searchTerm)
        .refreshable {
            await appModel.refreshFlavors()
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
                await appModel.addFlavor(name: newFlavor)
            }))).labelStyle(.iconOnly)
        }
    }
}
