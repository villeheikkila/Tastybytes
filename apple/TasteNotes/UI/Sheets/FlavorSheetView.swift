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
                    self.pickedFlavors.remove(object: flavor)
                
            } else {
                    self.pickedFlavors.append(flavor)
                
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
                self.pickedFlavors = initialFlavors
            
            
            if (availableFlavors.count == 0) {
                Task {
                    do {
                        let flavors = try await repository.flavor.getAll()
                        await MainActor.run {
                            self.availableFlavors = flavors
                        }
                    } catch {
                        print("error while loading flavors: \(error)")
                    }
                }
            }
        }
    }
}
