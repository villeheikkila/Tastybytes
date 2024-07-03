import Models
import OSLog
import Repositories
import SwiftUI

struct LocationEditSheet: View {
    let logger = Logger(category: "LocationEditSheet")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @State private var location: Location

    init(location: Location) {
        _location = State(initialValue: location)
    }

    var body: some View {
        Form {
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
            }

            Section("location.details.section.title") {
                VStack {
                    LabeledContent("labels.id", value: "\(location.id)")
                        .textSelection(.enabled)
                        .multilineTextAlignment(.trailing)
                    LabeledContent("location.mapKitIdentifier.label", value: "\(location.mapKitIdentifier ?? "-")")
                        .textSelection(.enabled)
                }
            }
        }
        .navigationTitle("admin.locations.edit.location.title")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItem(placement: .primaryAction) {
            RouterLink("admin.location.edit.attachLocation.label", systemImage: "map.circle", open: .sheet(.locationSearch(initialLocation: location, onSelect: { location in
                Task {
                    await updateLocation(self.location.copyWith(mapKitIdentifier: location.mapKitIdentifier))
                }
            })))
        }
    }

    public func updateLocation(_ location: Location) async {
        switch await repository.location.update(request: .init(id: location.id, mapKitIdentifier: location.mapKitIdentifier)) {
        case let .success(location):
            withAnimation {
                self.location = location
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Failed to update location: '\(location.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}
