import SwiftUI

struct FlavorSheetView: View {
    @Binding var pickedFlavors: [Flavor]
    @StateObject var viewModel = ViewModel()
    @State var searchText = ""
    @Environment(\.dismiss) var dismiss
    
    func toggleFlavor(_ flavor: Flavor) {
        if pickedFlavors.contains(flavor) {
            pickedFlavors.remove(object: flavor)

        } else {
            pickedFlavors.append(flavor)
        }
    }

    var filteredFlavors: [Flavor] {
        if searchText.isEmpty {
            return viewModel.availableFlavors
        } else {
            return viewModel.availableFlavors.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredFlavors, id: \.self) { flavor in
                Button(action: {
                    toggleFlavor(flavor)
                }) {
                    HStack {
                        Text(flavor.name.capitalized)
                        Spacer()
                        if pickedFlavors.contains(flavor) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            .navigationTitle("Flavors")
            .navigationBarItems(trailing: Button(action: {
                dismiss()
            }) {
                Text("Done").bold()
            })
            .task {
                viewModel.loadFlavors()
            }
            .searchable(text: $searchText)
        }
    }
}

extension FlavorSheetView {
    @MainActor class ViewModel: ObservableObject {
        @Published var availableFlavors = [Flavor]()


        func loadFlavors() {
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
