
import Logging
import Models
import Repositories
import SwiftUI

struct ProfileTopLocationsScreen: View {
    private let logger = Logger(label: "ProfileTopLocationsScreen")
    @Environment(Repository.self) private var repository
    @State private var state: ScreenState = .loading
    @State private var locations = [Profile.TopLocations]()

    let profile: Profile.Saved

    var body: some View {
        List(locations) { location in
            TopLocationRow(location: location, profile: profile)
        }
        .listStyle(.plain)
        .overlay {
            if state.isPopulated, locations.isEmpty {
                ContentUnavailableView("profileTopLocations.empty.title", systemImage: "tray")
            } else {
                ScreenStateOverlayView(state: state) {
                    await loadData()
                }
            }
        }
        .proMembershipOverlay()
        .initialTask {
            await loadData()
        }
    }

    private func loadData() async {
        do {
            let locations = try await repository.profile.getNumberOfCheckInsByLocation(id: profile.id)
            withAnimation {
                self.locations = locations
                state = .populated
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .error(error)
            logger.error("Failed loading top location statistics. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct TopLocationRow: View {
    let location: Profile.TopLocations
    let profile: Profile.Saved

    var body: some View {
        RouterLink(open: .screen(.profileCheckIns(profile, .location(location.loc)))) {
            HStack {
                if let coordinate = location.location?.coordinate {
                    MapThumbnail(location: location.loc, coordinate: coordinate, distance: nil)
                }
                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        Text(location.name)
                        if let title = location.title {
                            Text(title)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Text("(\(location.count.formatted()))")
                }
            }
        }
        .listRowBackground(Color.clear)
    }
}
