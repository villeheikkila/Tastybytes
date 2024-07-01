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
        switch await repository.profile.getNumberOfCheckInsByLocation(userId: profile.id) {
        case let .success(locations):
            withAnimation {
                self.locations = locations
                state = .populated
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed loading top location statistics. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct TopLocationRow: View {
    @Environment(Router.self) private var router

    let location: ProfileTopLocations
    let profile: Profile

    var body: some View {
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
                .contentShape(Rectangle())
                .accessibilityAddTraits(.isButton)
                Spacer()
                Text("(\(location.count.formatted()))")
            }
            .navigateOnTap(.screen(.profileCheckIns(profile, .location(location.loc))))
        }
        .listRowBackground(Color.clear)
    }
}
