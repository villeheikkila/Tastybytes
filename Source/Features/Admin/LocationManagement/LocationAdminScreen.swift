import EnvironmentModels
import Models
import Repositories
import SwiftUI

struct LocationAdminScreen: View {
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var state: ScreenState = .loading
    @State private var locations = [Location]()
    @State private var searchTerm = ""

    var filteredLocations: [Location] {
        if searchTerm.isEmpty {
            locations
        } else {
            locations.filter { $0.name.lowercased().contains(searchTerm.lowercased()) }
        }
    }

    var body: some View {
        List(filteredLocations) { location in
            LocationRow(location: location, currentLocation: nil) { location in
                router.open(.sheet(.locationAdmin(location: location, onEdit: { edited in
                    withAnimation {
                        locations = locations.replacing(location, with: edited)
                    }
                }, onDelete: { deleted in
                    withAnimation {
                        locations = locations.removing(deleted)
                    }
                })))
            }
        }
        .navigationTitle("admin.locations.title")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchTerm)
        .refreshable {
            await loadData()
        }
        .overlay {
            ScreenStateOverlayView(state: state, errorDescription: "") {
                await loadData()
            }
        }
        .initialTask {
            await loadData()
        }
    }

    private func loadData() async {
        switch await repository.location.getLocations() {
        case let .success(locations):
            withAnimation {
                self.locations = locations
                state = .populated
            }
        case let .failure(error):
            withAnimation {
                state = .getState(errors: [error], withHaptics: false, feedbackEnvironmentModel: feedbackEnvironmentModel)
            }
        }
    }
}
