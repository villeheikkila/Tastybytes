import Models
import SwiftUI

struct DiscoverLocationResults: View {
    let locations: [Location]

    var body: some View {
        ForEach(locations) { location in
            RouterLink(location.name, screen: .location(location))
                .id(location.id)
        }
    }
}
