import SwiftUI

extension LocationScreen {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "LocationScreen")
    let client: Client
    @Published var summary: Summary?
    @Published var showDeleteLocationConfirmation = false
    let location: Location

    init(_ client: Client, location: Location) {
      self.location = location
      self.client = client
    }

    func getSummary() async {
      switch await client.location.getSummaryById(id: location.id) {
      case let .success(summary):
        withAnimation {
          self.summary = summary
        }
      case let .failure(error):
        logger
          .error(
            "failed to get summary: \(error.localizedDescription)"
          )
      }
    }

    func deleteLocation(_ location: Location, onDelete: @escaping () -> Void) async {
      switch await client.location.delete(id: location.id) {
      case .success:
        onDelete()
      case let .failure(error):
        logger.error("failed to delete location: \(error.localizedDescription)")
      }
    }
  }
}
