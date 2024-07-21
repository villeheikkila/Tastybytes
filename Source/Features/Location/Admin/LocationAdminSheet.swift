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
    @State private var location = Location.Detailed()

    let id: Location.Id
    let onEdit: (_ location: Location) async -> Void
    let onDelete: (_ location: Location) async -> Void

    var body: some View {
        Form {
            if state == .populated {
                content
            }
        }
        .scrollContentBackground(.hidden)
        .animation(.default, value: location)
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
            LocationEntityView(location: .init(location: location))
        }
        .customListRowBackground()
        CreationInfoSection(createdBy: location.createdBy, createdAt: location.createdAt)
        Section("admin.section.details") {
            LabeledIdView(id: id.uuidString)
            LabeledContent("location.mapKitIdentifier.label", value: "\(location.mapKitIdentifier ?? "-")")
                .textSelection(.enabled)
        }
        .customListRowBackground()
        Section {
            RouterLink("admin.section.reports.title", systemImage: "exclamationmark.bubble", open: .screen(.reports(.location(location.id))))
            RouterLink("location.admin.changeLocation.label", systemImage: "map", open: .sheet(.locationSearch(initialLocation: .init(location: location), initialSearchTerm: location.name, onSelect: { location in
                let loc = self.location.copyWith(mapKitIdentifier: location.mapKitIdentifier)
                Task {
                    await updateLocation(loc)
                }
            })))
            RouterLink("location.admin.merge.label", systemImage: "arrow.triangle.merge", open: .sheet(.mergeLocation(location: location, onMerge: { newLocation in
                await onDelete(.init(location: location))
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

    private func loadData() async {
        do {
            let location = try await repository.location.getDetailed(id: id)
            self.location = location
            state = .populated
            await onEdit(.init(location: location))
        } catch {
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed to load location: '\(id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func updateLocation(_ location: Location.Detailed) async {
        do {
            let location = try await repository.location.update(request: .init(id: id, mapKitIdentifier: location.mapKitIdentifier))
            self.location = location
            await onEdit(.init(location: location))
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to update location: '\(location.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteLocation(_ location: Location.Detailed) async {
        do {
            try await repository.location.delete(id: id)
            await onDelete(.init(location: location))
            dismiss()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete location. Error: \(error) (\(#file):\(#line))")
        }
    }
}
