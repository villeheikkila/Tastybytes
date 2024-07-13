import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct ProfileTopLocationsScreen: View {
    private let logger = Logger(category: "ProfileTopLocationsScreen")
    @Environment(Repository.self) private var repository
    @State private var state: ScreenState = .loading
    @State private var locations = [ProfileTopLocations]()

    let profile: Profile

    var body: some View {
        List(locations) { location in
            TopLocationRow(location: location, profile: profile)
        }
        .listStyle(.plain)
        .overlay {
            if state == .populated, locations.isEmpty {
                ContentUnavailableView("profileTopLocations.empty.title", systemImage: "tray")
            } else {
                ScreenStateOverlayView(state: state, errorDescription: "") {
                    await loadData()
                }
            }
        }
        .initialTask {
            await loadData()
        }
    }

    func loadData() async {
        do {
            let locations = try await repository.profile.getNumberOfCheckInsByLocation(userId: profile.id)
            withAnimation {
                self.locations = locations
                state = .populated
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed loading top location statistics. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct TopLocationRow: View {
    let location: ProfileTopLocations
    let profile: Profile

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
