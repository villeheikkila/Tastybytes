import AlertToast
import SwiftUI

struct FlavorSheetView: View {
    let initialFlavors: [Flavor]
    let onComplete: (_ selectedFlavors: [Flavor]) -> Void
    @StateObject var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List(viewModel.filteredFlavors, id: \.self) { flavor in
                Button(action: {
                    viewModel.toggleFlavor(flavor)
                }) {
                    HStack {
                        Text(flavor.name.capitalized)
                        Spacer()
                        if viewModel.pickedFlavors.contains(flavor) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            .navigationTitle("Flavors")
            .navigationBarItems(trailing: Button(action: {
                onComplete(viewModel.pickedFlavors)
                dismiss()
            }) {
                Text("Done").bold()
            })
            .task {
                viewModel.loadFlavors(initialFlavors)
            }
            .searchable(text: $viewModel.searchText)
        }
    }
}

extension FlavorSheetView {
    @MainActor class ViewModel: ObservableObject {
        @Published var availableFlavors = [Flavor]()
        @Published var pickedFlavors = [Flavor]()
        @Published var showToast = false
        @Published var searchText = ""

        func toggleFlavor(_ flavor: Flavor) {
            if pickedFlavors.contains(flavor) {
                pickedFlavors.remove(object: flavor)

            } else {
                pickedFlavors.append(flavor)
            }
        }

        var filteredFlavors: [Flavor] {
            if searchText.isEmpty {
                return availableFlavors
            } else {
                return availableFlavors.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            }
        }

        func loadFlavors(_ initialFlavors: [Flavor]) {
            pickedFlavors = initialFlavors

            if availableFlavors.count == 0 {
                Task {
                    switch await repository.flavor.getAll() {
                    case let .success(flavors):
                        await MainActor.run {
                            self.availableFlavors = flavors
                        }
                    case let .failure(error):
                        print(error)
                    }
                }
            }
        }
    }
}
