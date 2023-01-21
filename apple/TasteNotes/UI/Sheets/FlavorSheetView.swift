import AlertToast
import SwiftUI

struct FlavorSheetView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject private var viewModel = ViewModel()
  @Binding var pickedFlavors: [Flavor]
  @State private var searchText = ""
  @State private var showToast = false
  let maxFlavors = 6

  func toggleFlavor(_ flavor: Flavor) {
    if pickedFlavors.contains(flavor) {
      pickedFlavors.remove(object: flavor)
    } else if pickedFlavors.count < maxFlavors {
      pickedFlavors.append(flavor)
    } else {
      showToast = true
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
    .toast(isPresenting: $showToast, duration: 2, tapToDismiss: true) {
      AlertToast(type: .error(.red), title: "You can only add \(maxFlavors) flavors")
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
