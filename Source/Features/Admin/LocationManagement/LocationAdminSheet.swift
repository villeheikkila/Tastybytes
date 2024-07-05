import Components
import MapKit
import Models
import OSLog
import Repositories
import SwiftUI

struct LocationAdminSheet: View {
    let logger = Logger(category: "LocationAdminSheet")
    @Environment(\.dismiss) private var dismiss
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @State private var state: ScreenState = .loading
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
            Section("location.admin.section.location") {
                if let coordinate = location.location?.coordinate {
                    Map(initialPosition: MapCameraPosition
                        .camera(.init(centerCoordinate: coordinate, distance: 200)))
                    {
                        Marker(location.name, coordinate: coordinate)
                        UserAnnotation()
                    }
                    .mapControls {
                        MapUserLocationButton()
                        MapCompass()
                    }
                    .frame(height: 150)
                    .listRowSeparator(.hidden)
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text(location.name)
                        if let title = location.title {
                            Text(title)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .contentShape(.rect)
                .openOnTap(.screen(.location(location)))
            }

            CreationInfoSection(createdBy: location.createdBy, createdAt: location.createdAt)

            Section("location.admin.section.details") {
                VStack {
                    LabeledContent("labels.id", value: "\(location.id)")
                        .textSelection(.enabled)
                        .multilineTextAlignment(.trailing)
                    LabeledContent("location.mapKitIdentifier.label", value: "\(location.mapKitIdentifier ?? "-")")
                        .textSelection(.enabled)
                }
            }

            Section {
                RouterLink("location.admin.changeLocation.label", systemImage: "map", open: .sheet(.locationSearch(initialLocation: location, initialSearchTerm: location.name, onSelect: { location in
                    Task {
                        await updateLocation(self.location.copyWith(mapKitIdentifier: location.mapKitIdentifier))
                    }
                })))
                RouterLink("location.admin.merge.label", systemImage: "arrow.triangle.merge", open: .sheet(.mergeLocationSheet(location: location, onMerge: { newLocation in
                    await onDelete(location)
                    withAnimation {
                        location = newLocation
                    }
                })))
            }

            Section {
                Button("labels.delete", systemImage: "trash", role: .destructive) {
                    showDeleteConfirmation = true
                }
                .tint(.red)
                .foregroundColor(.red)
                .confirmationDialog(
                    "location.delete.confirmation.description",
                    isPresented: $showDeleteConfirmation,
                    titleVisibility: .visible,
                    presenting: location
                ) { presenting in
                    ProgressButton(
                        "location.delete.confirmation.label \(presenting.name)",
                        role: .destructive,
                        action: { await deleteLocation(presenting) }
                    )
                }
            }
        }
        .navigationTitle("location.admin.location.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .task {
            await loadData()
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    func loadData() async {
        switch await repository.location.getDetailed(id: location.id) {
        case let .success(location):
            withAnimation {
                self.location = location
                state = .populated
            }
            await onEdit(location)
        case let .failure(error):
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed to update location: '\(location.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func updateLocation(_ location: Location) async {
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

    func deleteLocation(_ location: Location) async {
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
