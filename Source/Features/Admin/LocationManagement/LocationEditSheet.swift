import Components
import Models
import OSLog
import Repositories
import SwiftUI

struct LocationEditSheet: View {
    let logger = Logger(category: "LocationEditSheet")
    @Environment(\.dismiss) private var dismiss
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @State private var location: Location
    @State private var showDeleteConfirmation = false

    let onEdit: (_ location: Location) async -> Void
    let onDelete: (_ location: Location) async -> Void

    init(location: Location, onEdit: @escaping (_ location: Location) async -> Void, onDelete: @escaping (_ location: Location) async -> Void) {
        _location = State(initialValue: location)
        self.onEdit = onEdit
        self.onDelete = onDelete
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
        ToolbarItemGroup(placement: .primaryAction) {
            RouterLink("admin.location.edit.attachLocation.label", systemImage: "map.circle", open: .sheet(.locationSearch(initialLocation: location, onSelect: { location in
                Task {
                    await updateLocation(self.location.copyWith(mapKitIdentifier: location.mapKitIdentifier))
                }
            })))
            Button("labels.delete", systemImage: "trash") {
                showDeleteConfirmation = true
            }
            .confirmationDialog("labels.delete", isPresented: $showDeleteConfirmation, presenting: location) { location in
                ProgressButton("labels.delete", role: .destructive, action: {
                    await deleteLocation(location)
                })
            }
        }
    }

    public func updateLocation(_ location: Location) async {
        switch await repository.location.update(request: .init(id: location.id, mapKitIdentifier: location.mapKitIdentifier)) {
        case let .success(location):
            withAnimation {
                self.location = location
            }
            await onEdit(location)
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Failed to update location: '\(location.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteLocation(_ location: Location) async {
        switch await repository.location.delete(id: location.id) {
        case .success:
            await onDelete(location)
            dismiss()
        case let .failure(error):
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete location. Error: \(error) (\(#file):\(#line))")
        }
    }
}
