import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct MergeLocationSheet: View {
    private let logger = Logger(category: "MergeLocationSheet")
    @Environment(\.repository) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var alertError: AlertError?
    @Environment(\.dismiss) private var dismiss
    @State private var locations = [Location]()
    @State private var mergeToLocation: Location? {
        didSet {
            showMergeToProductConfirmation = true
        }
    }

    @State private var showMergeToProductConfirmation = false
    @State private var searchTerm = ""
    @State private var searchTask: Task<Void, Never>?

    let location: Location

    var shownLocations: [Location] {
        locations.filter { $0.id != location.id }
    }

    var body: some View {
        List(shownLocations) { location in
            Button(action: { mergeToLocation = location }, label: {
                Text(location.name)
            })
            .buttonStyle(.plain)
        }
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search for a duplicate location")
        .disableAutocorrection(true)
        .navigationTitle("Merge location to...")
        .toolbar {
            toolbarContent
        }
        .task(id: searchTerm, milliseconds: 200) {
            await searchLocations(name: searchTerm)
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

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            Button("Close", role: .cancel, action: { dismiss() }).bold()
        }
    }

    func mergeLocation(to: Location) async {
        switch await repository.location.mergeLocations(locationId: location.id, toLocationId: to.id) {
        case .success:
            feedbackEnvironmentModel.trigger(.notification(.success))
            await MainActor.run {
                dismiss()
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
            logger.error("Merging location failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    func searchLocations(name: String) async {
        guard name.count > 1 else { return }
        switch await repository.location.search(searchTerm: name) {
        case let .success(searchResults):
            locations = searchResults
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            alertError = .init()
            logger.error("Searching locations failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
