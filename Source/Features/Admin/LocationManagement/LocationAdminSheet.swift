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
            content
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("location.admin.location.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .task {
            await loadData()
        }
    }

    @ViewBuilder private var content: some View {
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
            RouterLink(open: .screen(.location(location))) {
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
            }
        }
        .customListRowBackground()
        CreationInfoSection(createdBy: location.createdBy, createdAt: location.createdAt)
        Section("admin.section.details") {
            LabeledIdView(id: location.id.uuidString)
            LabeledContent("location.mapKitIdentifier.label", value: "\(location.mapKitIdentifier ?? "-")")
                .textSelection(.enabled)
        }
        .customListRowBackground()
        Section {
            RouterLink("location.admin.changeLocation.label", systemImage: "map", open: .sheet(.locationSearch(initialLocation: location, initialSearchTerm: location.name, onSelect: { location in
                Task {
                    await updateLocation(self.location.copyWith(mapKitIdentifier: location.mapKitIdentifier))
                }
            })))
            RouterLink("location.admin.merge.label", systemImage: "arrow.triangle.merge", open: .sheet(.mergeLocation(location: location, onMerge: { newLocation in
                await onDelete(location)
                withAnimation {
                    location = newLocation
                }
            })))
        }
        .customListRowBackground()
        Section {
            ConfirmedDeleteButtonView(
                presenting: location,
                action: deleteLocation,
                description: "location.delete.confirmation.description",
                label: "location.delete.confirmation.label \(location.name)",
                isDisabled: false
            )
        }
        .customListRowBackground()
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    func loadData() async {
        do {
            let location = try await repository.location.getDetailed(id: location.id)
            withAnimation {
                self.location = location
                state = .populated
            }
            await onEdit(location)
        } catch {
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed to update location: '\(location.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func updateLocation(_ location: Location) async {
        do { let location = try await repository.location.update(request: .init(id: location.id, mapKitIdentifier: location.mapKitIdentifier))
            withAnimation {
                self.location = location
            }
            await onEdit(location)
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to update location: '\(location.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteLocation(_ location: Location) async {
        do {
            try await repository.location.delete(id: location.id)
            await onDelete(location)
            dismiss()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete location. Error: \(error) (\(#file):\(#line))")
        }
    }
}
