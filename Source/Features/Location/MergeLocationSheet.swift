import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct MergeLocationSheet: View {
    private let logger = Logger(category: "MergeLocationSheet")
    @Environment(Repository.self) private var repository
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var alertError: AlertError?
    @Environment(\.dismiss) private var dismiss
    @State private var locations = [Location]()
    @State private var mergeToLocation: Location?
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
                    prompt: "location.mergeTo.search.placeholder")
        .disableAutocorrection(true)
        .navigationTitle("location.mergeTo.navigationTitle.")
        .toolbar {
            toolbarContent
        }
        .task(id: searchTerm, milliseconds: 200) { @MainActor in
            await searchLocations(name: searchTerm)
        }
        .confirmationDialog(
            "location.merge.confirmation.description",
            isPresented: $mergeToLocation.isNotNull(),
            titleVisibility: .visible,
            presenting: mergeToLocation
        ) { presenting in
            ProgressButton(
                "location.merge.confirmation.label \(location.name) \(presenting.name)",
                role: .destructive
            ) {
                await mergeLocation(to: presenting)
            }
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    func mergeLocation(to: Location) async {
        switch await repository.location.mergeLocations(locationId: location.id, toLocationId: to.id) {
        case .success:
            feedbackEnvironmentModel.trigger(.notification(.success))
            dismiss()
        case let .failure(error):
            guard !error.isCancelled else { return }
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
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Searching locations failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}
