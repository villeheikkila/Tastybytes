import Components

import Extensions
import Models
import SwiftUI

struct FlavorPickerSheet: View {
    @Environment(AppModel.self) private var appModel
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @Binding var pickedFlavors: [Flavor.Saved]
    @State private var searchTerm = ""

    private let maxFlavors = 4

    private var filteredFlavors: [Flavor.Saved] {
        appModel.flavors.filteredBySearchTerm(by: \.name, searchTerm: searchTerm)
    }

    private var showContentUnavailableView: Bool {
        !searchTerm.isEmpty && filteredFlavors.isEmpty
    }

    private var availableFlavours: [Flavor.Saved] {
        appModel.flavors
    }

    var body: some View {
        List(filteredFlavors.sorted(by: { pickedFlavors.contains($0) && !pickedFlavors.contains($1) }), selection: $pickedFlavors.map(getter: { flavors in
            Set(flavors.map(\.id))
        }, setter: { ids in
            Array(ids.compactMap { id in availableFlavours.first(where: { $0.id == id }) })
        })) { flavor in
            FlavorView(flavor: flavor)
                .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 48)
        .environment(\.editMode, .constant(.active))
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("flavor.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            ContentUnavailableView.search(text: searchTerm)
                .opacity(showContentUnavailableView ? 1 : 0)
        }
        .onChange(of: pickedFlavors) { oldValue, newValue in
            if newValue.count > maxFlavors {
                pickedFlavors = pickedFlavors.removing(newValue.addedValues(oldValue))
                router.open(.toast(.error("flavor.add.maxAmountReached.toast \(maxFlavors)")))
            }
        }
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }
}
