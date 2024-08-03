import Components
import Extensions
import MapKit
import Models
import OSLog
import Repositories
import SwiftUI

struct LocationAdminSheet: View {
    typealias OnEditCallback = (_ location: Location.Detailed) async -> Void
    typealias OnDeleteCallback = (_ location: Location.Detailed) async -> Void

    enum Open {
        case report(Report.Id)
    }

    let logger = Logger(category: "LocationAdminSheet")
    @Environment(\.dismiss) private var dismiss
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @State private var state: ScreenState = .loading
    @State private var location = Location.Detailed()

    let id: Location.Id
    let open: Open?
    let onEdit: OnEditCallback
    let onDelete: OnDeleteCallback

    var body: some View {
        Form {
            if state.isPopulated {
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
        .initialTask {
            await initialize()
        }
    }

    @ViewBuilder private var content: some View {
        Section("location.admin.section.location") {
            LocationView(location: .init(location: location))
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
            RouterLink(
                "admin.section.reports.title",
                systemImage: "exclamationmark.bubble",
                badge: location.reports.count,
                open: .screen(
                    .reports(reports: $location.map(getter: { location in
                        location.reports
                    }, setter: { reports in
                        location.copyWith(reports: reports)
                    }))
                )
            )
            RouterLink("location.admin.changeLocation.label", systemImage: "map", open: .sheet(.locationSearch(initialLocation: .init(location: location), initialSearchTerm: location.name, onSelect: { location in
                let loc = self.location.copyWith(mapKitIdentifier: location.mapKitIdentifier)
                Task {
                    await updateLocation(loc)
                }
            })))
            RouterLink("location.admin.merge.label", systemImage: "arrow.triangle.merge", open: .sheet(.mergeLocation(location: location, onMerge: { newLocation in
                await onDelete(location)
                location = newLocation
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

    private func initialize() async {
        do {
            let location = try await repository.location.getDetailed(id: id)
            self.location = location
            state = .populated
            await onEdit(location)
            if let open {
                switch open {
                case let .report(id):
                    router.open(.screen(
                        .reports(reports: $location.map(getter: { profile in
                            profile.reports
                        }, setter: { reports in
                            location.copyWith(reports: reports)
                        }), initialReport: id)))
                }
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .error(error)
            logger.error("Failed to load location: '\(id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func updateLocation(_ location: Location.Detailed) async {
        do {
            let location = try await repository.location.update(request: .init(id: id, mapKitIdentifier: location.mapKitIdentifier))
            self.location = location
            await onEdit(location)
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to update location: '\(location.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteLocation(_ location: Location.Detailed) async {
        do {
            try await repository.location.delete(id: id)
            await onDelete(location)
            dismiss()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete location. Error: \(error) (\(#file):\(#line))")
        }
    }
}
