import SwiftUI

struct LocationSearchSheet: View {
  @StateObject private var viewModel: ViewModel
  @StateObject private var locationManager = LocationManager()
  @Environment(\.dismiss) private var dismiss

  var onSelect: (_ location: Location) -> Void

  init(_ client: Client, onSelect: @escaping (_ location: Location) -> Void) {
    _viewModel = StateObject(wrappedValue: ViewModel(client))
    self.onSelect = onSelect
  }

  var body: some View {
    List(viewModel.locations) { location in
      ProgressButton(action: {
        await viewModel.storeLocation(location, onSuccess: { savedLocation in
          onSelect(savedLocation)
          dismiss()
        })
      }, label: {
        VStack(alignment: .leading) {
          Text(location.name)
          if let title = location.title {
            Text(title)
              .foregroundColor(.secondary)
          }
        }
      })
    }
    .navigationBarItems(trailing: Button(role: .cancel, action: {
      dismiss()
    }, label: {
      Text("Cancel").bold()
    }))
    .navigationTitle("Location")
    .searchable(text: $viewModel.searchText)
    .task {
      guard let lastLocation = locationManager.lastLocation else { return }
      viewModel.setInitialLocation(lastLocation)
      await viewModel.getSuggestions(lastLocation)
    }
  }
}
