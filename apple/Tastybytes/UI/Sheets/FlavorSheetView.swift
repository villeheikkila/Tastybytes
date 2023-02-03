import AlertToast
import SwiftUI

struct FlavorSheetView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel = ViewModel()
  @Binding var pickedFlavors: [Flavor]
  @State private var searchText = ""
  @State private var showToast = false

  private let maxFlavors = 6

  var body: some View {
    List(filteredFlavors, id: \.self) { flavor in
      Button(action: {
        withAnimation {
          toggleFlavor(flavor)
        }
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

  private func toggleFlavor(_ flavor: Flavor) {
    if pickedFlavors.contains(flavor) {
      withAnimation {
        pickedFlavors.remove(object: flavor)
      }
    } else if pickedFlavors.count < maxFlavors {
      withAnimation {
        pickedFlavors.append(flavor)
      }
    } else {
      showToast = true
    }
  }

  private var filteredFlavors: [Flavor] {
    if searchText.isEmpty {
      return viewModel.availableFlavors
    } else {
      return viewModel.availableFlavors.filter { $0.name.lowercased().contains(searchText.lowercased()) }
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
            withAnimation {
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
