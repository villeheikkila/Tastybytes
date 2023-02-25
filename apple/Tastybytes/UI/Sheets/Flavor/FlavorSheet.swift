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
          ForEach(pickedFlavors, id: \.id) { pickedFlavor in
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
      Section {
        ForEach(viewModel.filteredFlavors.filter { !pickedFlavors.contains($0) }, id: \.id) { flavor in
          Button(action: { toggleFlavor(flavor) }, label: {
            HStack {
              Text(flavor.name.capitalized)
              Spacer()
              if pickedFlavors.contains(flavor) {
                Label("Pick the flavor", systemImage: "checkmark")
                  .labelStyle(.iconOnly)
              }
            }
          })
        }
      } header: {
        Text("Available flavors")
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
