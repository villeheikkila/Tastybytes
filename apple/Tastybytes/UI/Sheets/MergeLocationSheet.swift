import SwiftUI

struct MergeLocationSheet: View {
  private let logger = getLogger(category: "MergeLocationSheet")
  @Environment(Repository.self) private var repository
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @EnvironmentObject private var router: Router
  @Environment(\.dismiss) private var dismiss
  @State private var locations = [Location]()
  @State private var mergeToLocation: Location? {
    didSet {
      showMergeToProductConfirmation = true
    }
  }

  @State private var showMergeToProductConfirmation = false
  @State private var searchTerm = ""

  let location: Location

  var shownLocations: [Location] {
    locations.filter { $0.id != location.id }
  }

  var body: some View {
    List {
      ForEach(shownLocations) { location in
        Button(action: { mergeToLocation = location }, label: {
          Text(location.name)
        })
        .buttonStyle(.plain)
      }
    }
    .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search for a duplicate location")
    .disableAutocorrection(true)
    .onSubmit(of: .search) {
      Task { await searchLocations(name: searchTerm) }
    }
    .navigationTitle("Merge location to...")
    .navigationBarItems(leading: Button("Close", role: .cancel, action: { dismiss() }))
    .onChange(of: searchTerm, debounceTime: 0.2) { newValue in
      Task { await searchLocations(name: newValue) }
    }
    .confirmationDialog(
      "Are you sure you want to merge these locations? All check-ins will be transfered and old location deleted.",
      isPresented: $showMergeToProductConfirmation,
      titleVisibility: .visible,
      presenting: mergeToLocation
    ) { presenting in
      ProgressButton(
        "Merge \(location.name) to \(presenting.name)",
        role: .destructive
      ) {
        await mergeLocation(to: presenting)
      }
    }
  }

  func mergeLocation(to: Location) async {
    switch await repository.location.mergeLocations(locationId: location.id, toLocationId: to.id) {
    case .success:
      feedbackManager.trigger(.notification(.success))
      dismiss()
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("merging location failed: \(error.localizedDescription)")
    }
  }

  func searchLocations(name: String) async {
    guard name.count > 1 else { return }
    switch await repository.location.search(searchTerm: name) {
    case let .success(searchResults):
      locations = searchResults
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("searching locations failed: \(error.localizedDescription)")
    }
  }
}
