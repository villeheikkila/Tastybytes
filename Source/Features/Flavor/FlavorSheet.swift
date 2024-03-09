import Components
import EnvironmentModels
import Extensions
import Models
import SwiftUI

@MainActor
struct FlavorSheet: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @Binding var pickedFlavors: [Flavor]
    @State private var searchTerm = ""

    private let maxFlavors = 4

    private var filteredFlavors: [Flavor] {
        if searchTerm.isEmpty {
            appEnvironmentModel.flavors
        } else {
            appEnvironmentModel.flavors.filter { $0.name.lowercased().contains(searchTerm.lowercased()) }
        }
    }

    private var showContentUnavailableView: Bool {
        !searchTerm.isEmpty && filteredFlavors.isEmpty
    }

    var body: some View {
        List(filteredFlavors.sorted(by: { pickedFlavors.contains($0) && !pickedFlavors.contains($1) }), selection: $pickedFlavors.map(getter: { flavors in
            Set(flavors.map(\.id))
        }, setter: { ids in
            Array(ids.compactMap { id in appEnvironmentModel.flavors.first(where: { $0.id == id }) })
        })) { pickedFlavor in
            Text(pickedFlavor.name.capitalized)
                .listRowBackground(Color.clear)
        }
        .environment(\.defaultMinListRowHeight, 48)
        .environment(\.editMode, .constant(.active))
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("flavor.navigationTitle")
        .overlay {
            ContentUnavailableView.search(text: searchTerm)
                .opacity(showContentUnavailableView ? 1 : 0)
        }
        .onChange(of: pickedFlavors) { oldValue, newValue in
            let added = Set(newValue).addedValueTo(Set(oldValue))
            if let added, newValue.count > maxFlavors {
                pickedFlavors = pickedFlavors.removing(added)
                feedbackEnvironmentModel.toggle(.warning("flavor.add.maxAmountReached.toast \(maxFlavors)"))
                return
            }
        }
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDoneActionView()
    }
}
