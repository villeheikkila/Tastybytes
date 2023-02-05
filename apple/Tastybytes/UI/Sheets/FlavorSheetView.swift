import AlertToast
import SwiftUI

struct FlavorSheetView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: ViewModel
  @Binding private var pickedFlavors: [Flavor]
  @State private var showToast = false

  init(_ client: Client, pickedFlavors: Binding<[Flavor]>) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
    _pickedFlavors = pickedFlavors
  }

  var body: some View {
    List(viewModel.filteredFlavors, id: \.id) { flavor in
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
      AlertToast(type: .error(.red), title: "You can only add \(viewModel.maxFlavors) flavors")
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
    .searchable(text: $viewModel.searchTerm)
  }

  private func toggleFlavor(_ flavor: Flavor) {
    if pickedFlavors.contains(flavor) {
      pickedFlavors.remove(object: flavor)
    } else if pickedFlavors.count < viewModel.maxFlavors {
      pickedFlavors.append(flavor)
    } else {
      showToast = true
    }
  }
}

extension FlavorSheetView {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "FlavorSheetView")
    let client: Client
    @Published var availableFlavors = [Flavor]()
    @Published var searchTerm = ""

    let maxFlavors = 4

    init(_ client: Client) {
      self.client = client
    }

    var filteredFlavors: [Flavor] {
      if searchTerm.isEmpty {
        return availableFlavors
      } else {
        return availableFlavors.filter { $0.name.lowercased().contains(searchTerm.lowercased()) }
      }
    }

    func loadFlavors() {
      if availableFlavors.count == 0 {
        Task {
          switch await client.flavor.getAll() {
          case let .success(flavors):
            withAnimation {
              self.availableFlavors = flavors
            }
          case let .failure(error):
            logger
              .error(
                "fetching flavors failed: \(error.localizedDescription)"
              )
          }
        }
      }
    }
  }
}
