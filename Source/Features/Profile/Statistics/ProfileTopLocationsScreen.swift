import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct ProfileTopLocationsScreen: View {
    private let logger = Logger(category: "ProfileTopLocationsScreen")
    @Environment(Repository.self) private var repository
    @State private var locations = [ProfileTopLocations]()
    @State private var isLoading = false

    let profile: Profile

    var body: some View {
        List(locations) { location in
            TopLocationRow(location: location, profile: profile)
        }
        .listStyle(.plain)
        .initialTask {
            await loadData()
        }
    }

    func loadData() async {
        guard isLoading == false else { return }
        isLoading = true
        switch await repository.profile.getNumberOfCheckInsByLocation(userId: profile.id) {
        case let .success(locations):
            withAnimation {
                self.locations = locations
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Failed loading top location statistics. Error: \(error) (\(#file):\(#line))")
        }
        isLoading = false
    }
}

@MainActor
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
