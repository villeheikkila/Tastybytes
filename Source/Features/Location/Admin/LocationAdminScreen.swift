import EnvironmentModels
import Extensions
import Models
import Repositories
import SwiftUI

struct LocationAdminScreen: View {
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @State private var state: ScreenState = .loading
    @State private var locations = [Location.Saved]()
    @State private var searchTerm = ""

    private var filteredLocations: [Location.Saved] {
        locations.filteredBySearchTerm(by: \.name, searchTerm: searchTerm)
    }

    var body: some View {
        List(filteredLocations) { location in
            LocationRow(location: location, currentLocation: nil) { location in
                router.open(.sheet(.locationAdmin(id: location.id, onEdit: { edited in
                    let updatedLocation = Location.Saved(location: edited)
                    withAnimation {
                        locations = locations.replacing(location, with: updatedLocation)
                    }
                }, onDelete: { deleted in
                    withAnimation {
                        locations = locations.removingWithId(deleted.id)
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
            ScreenStateOverlayView(state: state) {
                await loadData()
            }
        }
        .initialTask {
            await loadData()
        }
    }

    private func loadData() async {
        do {
            let locations = try await repository.location.getLocations()
            withAnimation {
                self.locations = locations
                state = .populated
            }
        } catch {
            withAnimation {
                state = .getState(errors: [error], withHaptics: false, feedbackEnvironmentModel: feedbackEnvironmentModel)
            }
        }
    }
}
