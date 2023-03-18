import AlertToast
import SwiftUI

struct FlavorSheet: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: ViewModel
  @Binding private var pickedFlavors: [Flavor]
  @State private var showToast = false

  init(_ client: Client, pickedFlavors: Binding<[Flavor]>) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
    _pickedFlavors = pickedFlavors
  }

  var body: some View {
    List {
      if !pickedFlavors.isEmpty {
        Section {
          ForEach(pickedFlavors) { pickedFlavor in
            Button(action: { toggleFlavor(pickedFlavor) }, label: {
              HStack {
                Text(pickedFlavor.name.capitalized)
                Spacer()
              }
            })
          }
        } header: {
          Text("Picked flavors")
        }
      }

      if !viewModel.searchTerm.isEmpty, !viewModel.filteredFlavors.contains { !pickedFlavors.contains($0) } {
        Section {
          Text("No flavors found with the search term")
        }
      }

      Section {
        ForEach(viewModel.filteredFlavors.filter { !pickedFlavors.contains($0) }) { flavor in
          Button(action: { toggleFlavor(flavor) }, label: {
            HStack {
              Text(flavor.label)
              Spacer()
              if pickedFlavors.contains(flavor) {
                Label("Picked flavor", systemImage: "checkmark")
                  .labelStyle(.iconOnly)
              }
            }
          })
        }
      } header: {
        if viewModel.filteredFlavors.contains { !pickedFlavors.contains($0) } {
          Text("Available flavors")
        }
      }
    }
    .toast(isPresenting: $showToast, duration: 2, tapToDismiss: true) {
      AlertToast(type: .error(.red), title: "You can only add \(viewModel.maxFlavors) flavors")
    }
    .navigationTitle("Flavors")
    .navigationBarItems(trailing: Button(action: { dismiss() }, label: {
      Text("Done").bold()
    }))
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
