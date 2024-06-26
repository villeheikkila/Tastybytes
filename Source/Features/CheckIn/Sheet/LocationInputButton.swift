import Models
import SwiftUI

struct LocationInputButton: View {
    @Environment(Router.self) private var router
    let category: Location.RecentLocation
    let title: LocalizedStringKey
    @Binding var selection: Location?
    @Binding var initialLocation: Location?
    let onSelect: (_ location: Location) -> Void

    var body: some View {
        Button(
            action: { router.openSheet(.locationSearch(category: category, title: title, initialLocation: $initialLocation, onSelect: onSelect)) },
            label: {
                HStack {
                    if let location = selection, let coordinate = selection?.location?.coordinate {
                        MapThumbnail(location: location, coordinate: coordinate, distance: nil)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)

                        if let selection {
                            Text(selection.name)
                                .foregroundColor(.secondary)

                            if let locationTitle = selection.title {
                                Text(locationTitle)
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                    Spacer()
                    if selection != nil {
                        Button("checkIn.location.reset", systemImage: "xmark") {
                            selection = nil
                        }.labelStyle(.iconOnly)
                    }
                }
            }
        )
    }
}
