import AlertToast
import SwiftUI

struct FlavorSheet: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var appDataManager: AppDataManager
  @Binding var pickedFlavors: [Flavor]
  @State private var showToast = false
  @State private var searchTerm = ""

  private let maxFlavors = 4

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

      if !searchTerm.isEmpty, !filteredFlavors.contains { !pickedFlavors.contains($0) } {
        Section {
          Text("No flavors found with the search term")
        }
      }

      Section {
        ForEach(filteredFlavors.filter { !pickedFlavors.contains($0) }) { flavor in
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
        if filteredFlavors.contains { !pickedFlavors.contains($0) } {
          Text("Available flavors")
        }
      }
    }
    .toast(isPresenting: $showToast, duration: 2, tapToDismiss: true) {
      AlertToast(type: .error(.red), title: "You can only add \(maxFlavors) flavors")
    }
    .navigationTitle("Flavors")
    .navigationBarItems(trailing: Button(action: { dismiss() }, label: {
      Text("Done").bold()
    }))
    .searchable(text: $searchTerm)
  }

  private var filteredFlavors: [Flavor] {
    if searchTerm.isEmpty {
      return appDataManager.flavors
    } else {
      return appDataManager.flavors.filter { $0.name.lowercased().contains(searchTerm.lowercased()) }
    }
  }

  private func toggleFlavor(_ flavor: Flavor) {
    if pickedFlavors.contains(flavor) {
      pickedFlavors.remove(object: flavor)
    } else if pickedFlavors.count < maxFlavors {
      pickedFlavors.append(flavor)
    } else {
      showToast = true
    }
  }
}
