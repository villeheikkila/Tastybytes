import EnvironmentModels
import Extensions
import Models
import SwiftUI

struct FlavorSheet: View {
    @Environment(AppDataEnvironmentModel.self) private var appDataEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @Binding var pickedFlavors: [Flavor]
    @State var pickedFlavorIds: Set<Int> = Set()
    @State private var searchTerm = ""

    init(pickedFlavors: Binding<[Flavor]>) {
        _pickedFlavors = pickedFlavors
        _pickedFlavorIds = State(initialValue: Set(pickedFlavors.map(\.id)))
    }

    private let maxFlavors = 4

    private var filteredFlavors: [Flavor] {
        if searchTerm.isEmpty {
            return appDataEnvironmentModel.flavors
        } else {
            return appDataEnvironmentModel.flavors.filter { $0.name.lowercased().contains(searchTerm.lowercased()) }
        }
    }

    private var sortedFlavors: [Flavor] {
        filteredFlavors
            .sorted { pickedFlavorIds.contains($0.id) && !pickedFlavorIds.contains($1.id) }
    }

    private var pickedFlavorIdsAsFlavors: [Flavor] {
        pickedFlavorIds.compactMap { flavor in
            appDataEnvironmentModel.flavors.first(where: { $0.id == flavor })
        }
    }

    private var showContentUnavailableView: Bool {
        !searchTerm.isEmpty && filteredFlavors.isEmpty
    }

    var body: some View {
        List(sortedFlavors, selection: $pickedFlavorIds) { pickedFlavor in
            Text(pickedFlavor.name.capitalized)
        }
        .environment(\.defaultMinListRowHeight, 32)
        .environment(\.editMode, .constant(.active))
        .searchable(text: $searchTerm)
        .navigationTitle("Flavors")
        .overlay {
            ContentUnavailableView.search(text: searchTerm)
                .opacity(showContentUnavailableView ? 1 : 0)
        }
        .onChange(of: pickedFlavorIds) { oldValue, newValue in
            let added = newValue.addedValueTo(oldValue)
            if let added, newValue.count > maxFlavors {
                pickedFlavorIds.remove(added)
                feedbackEnvironmentModel.toggle(.warning("You can only add \(maxFlavors) flavors"))
                return
            }
        }
        .onChange(of: pickedFlavorIds) {
            pickedFlavors = pickedFlavorIdsAsFlavors
        }
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .confirmationAction) {
            Button("Done", action: { dismiss() }).bold()
        }
    }
}
