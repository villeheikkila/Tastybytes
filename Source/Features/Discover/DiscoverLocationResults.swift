import Models
import SwiftUI

struct DiscoverLocationResults: View {
    let locations: [Location]

    var body: some View {
        ForEach(locations) { location in
            RouterLink(open: .screen(.location(location))) {
                HStack {
                    if let coordinate = location.location?.coordinate {
                        MapThumbnail(location: location, coordinate: coordinate, distance: nil)
                    }
                    VStack(alignment: .leading) {
                        Text(location.name)
                        if let title = location.title {
                            Text(title)
                                .foregroundColor(.secondary)
                        }
                    }
                    .contentShape(.rect)
                    .accessibilityAddTraits(.isButton)
                }

            }
            .listRowBackground(Color.clear)
            .id(location.id)
        }
    }
}
