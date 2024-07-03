import Models
import SwiftUI

struct LocationEditSheet: View {
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
            RouterLink("admin.location.edit.attachLocation.label", systemImage: "map.circle", open: .sheet(.barcodeScanner(onComplete: { barcode in
                print(barcode)
            })))
        }
    }
}
