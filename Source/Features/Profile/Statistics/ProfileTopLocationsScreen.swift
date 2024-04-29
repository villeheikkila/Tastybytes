import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct ProfileTopLocationsScreen: View {
    private let logger = Logger(category: "ProfileTopLocationsScreen")
    @Environment(Router.self) private var router
    @Environment(Repository.self) private var repository
    @State private var locations = [ProfileTopLocations]()
    @State private var isLoading = false

    let profile: Profile

    var body: some View {
        List(locations) { location in
            LocationRow(location: location.loc) { location in
                router.navigate(screen: .location(location))
            }
        }.initialTask {
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
