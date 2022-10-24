import AlertToast
import SwiftUI

struct FlavorPickerView: View {
    @Binding var availableFlavors: [Flavor]
    @Binding var pickedFlavors: [Flavor]
    @State var showToast = false
    @State var searchText = ""
    @Environment(\.dismiss) var dismiss
    
    func toggleFlavor(_ flavor: Flavor) {
        if pickedFlavors.contains(flavor) {
            pickedFlavors.remove(object: flavor)
        } else {
            pickedFlavors.append(flavor)
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
                loadFlavors()
            }
            .searchable(text: $searchText)
        }
    }
    
    var filteredFlavors: [Flavor] {
        if searchText.isEmpty {
            return availableFlavors
        } else {
            return availableFlavors.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    func loadFlavors() {
        if (availableFlavors.count == 0) {
            Task {
                do {
                    let flavors = try await repository.flavor.getAll()
                    DispatchQueue.main.async {
                        self.availableFlavors = flavors
                    }
                } catch {
                    print("error while loading flavors: \(error)")
                }
            }
        }
    }
}
