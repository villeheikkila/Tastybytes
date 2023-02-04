import Combine
import MapKit
import SwiftUI

struct LocationSearchView: View {
  @StateObject private var viewModel = ViewModel()
  @StateObject private var locationManager = LocationManager()
  @Environment(\.dismiss) private var dismiss

  var onSelect: (_ location: Location) -> Void

  var body: some View {
    List(viewModel.viewData, id: \.self) { location in
      Button(action: {
        viewModel.storeLocation(location, onSuccess: {
          savedLocation in onSelect(savedLocation)
          dismiss()
        })
      }) {
        VStack(alignment: .leading) {
          Text(location.name)
          if let title = location.title {
            Text(title)
              .foregroundColor(.secondary)
          }
        }
      }
    }
    .navigationBarItems(trailing: Button(action: {
      dismiss()
    }) {
      Text("Cancel").bold()
    })
    .navigationTitle("Location")
    .searchable(text: $viewModel.searchText)
    .task {
      viewModel.setInitialLocation(locationManager.lastLocation)
    }
  }
}

extension LocationSearchView {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "LocationSearchView")
    var service: LocationSearchService
    private var cancellable: AnyCancellable?
    @Published var viewData = [Location]()
    @Published var searchText = "" {
      didSet {
        searchForLocation(text: searchText)
      }
    }

    func storeLocation(_ location: Location, onSuccess: @escaping (_ savedLocation: Location) -> Void) {
      Task {
        switch await repository.location.insert(location: location) {
        case let .success(savedLocation):
          print("saved: \(savedLocation)")
          onSuccess(savedLocation)
        case let .failure(error):
          print("error: \(error)")

          print(error)
        }
      }
    }

    func setInitialLocation(_ location: CLLocation?) {
      let latitude = location?.coordinate.latitude ?? 60.1699
      let longitutde = location?.coordinate.longitude ?? 24.9384
      let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitutde)
      service.setCenter(in: center)
    }

    init() {
      service = LocationSearchService()
      cancellable = service.localSearchPublisher.sink { mapItems in
        self.viewData = mapItems.map { Location(mapItem: $0) }
      }
    }

    private func searchForLocation(text _: String) {
      service.searchLocation(resultType: .pointOfInterest, searchText: searchText)
    }
  }
}
