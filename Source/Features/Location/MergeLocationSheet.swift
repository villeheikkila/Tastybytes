import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct MergeLocationSheet: View {
    private let logger = Logger(category: "MergeLocationSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var locations = [Location]()
    @State private var mergeToLocation: Location?
    @State private var searchTerm = ""
    @State private var searchTask: Task<Void, Never>?

    let location: Location.Detailed
    let onMerge: ((_ newLocation: Location.Detailed) async -> Void)?

    init(location: Location.Detailed, onMerge: ((_: Location.Detailed) async -> Void)? = nil) {
        self.location = location
        self.onMerge = onMerge
    }

    var shownLocations: [Location] {
        locations.filter { $0.id != location.id }
    }

    var body: some View {
        List(shownLocations) { mergeToLocation in
            MergeLocationSheetRow(
                mergeToLocation: mergeToLocation,
                locationToMerge: location,
                mergeLocation: mergeLocation
            )
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "location.mergeTo.search.placeholder")
        .disableAutocorrection(true)
        .navigationTitle("location.mergeTo.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .task(id: searchTerm, milliseconds: 200) {
            await searchLocations(name: searchTerm)
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    private func mergeLocation(_ to: Location) async {
        do {
            try await repository.location.mergeLocations(locationId: location.id, toLocationId: to.id)
            let location = try await repository.location.getDetailed(id: to.id)
            feedbackEnvironmentModel.trigger(.notification(.success))
            if let onMerge {
                await onMerge(location)
            }
            dismiss()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Merging location failed. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func searchLocations(name: String) async {
        guard name.count > 1 else { return }
        do {
            let searchResults = try await repository.location.search(searchTerm: name)
            locations = searchResults
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Searching locations failed. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct MergeLocationSheetRow: View {
    @State private var showMergeToConfirmation = false

    let mergeToLocation: Location
    let locationToMerge: Location.Detailed
    let mergeLocation: (_ location: Location) async -> Void

    var body: some View {
        LocationRow(location: mergeToLocation, currentLocation: nil, onSelect: { _ in showMergeToConfirmation = true })
            .confirmationDialog(
                "location.merge.confirmation.description",
                isPresented: $showMergeToConfirmation,
                titleVisibility: .visible,
                presenting: mergeToLocation
            ) { presenting in
                AsyncButton(
                    "location.merge.confirmation.label \(mergeToLocation.name) \(presenting.name)",
                    role: .destructive
                ) {
                    await mergeLocation(presenting)
                }
            }
    }
}
