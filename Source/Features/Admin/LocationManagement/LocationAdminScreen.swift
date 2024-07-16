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
    @State private var locations = [Location]()
    @State private var searchTerm = ""

    private var filteredLocations: [Location] {
        locations.filteredBySearchTerm(by: \.name, searchTerm: searchTerm)
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
