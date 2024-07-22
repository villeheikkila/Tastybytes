import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInAdminSheet: View {
    private let logger = Logger(category: "CheckInAdminSheet")
    @Environment(\.dismiss) private var dismiss
    @Environment(Router.self) private var router
    @Environment(Repository.self) private var repository
    @State private var state: ScreenState = .loading
    @State private var checkIn = CheckIn.Detailed()

    let id: CheckIn.Id
    let onDelete: () -> Void

    var body: some View {
        Form {
            if state.isPopulated {
                content
            }
        }
        .scrollContentBackground(.hidden)
        .animation(.default, value: checkIn)
        .overlay {
            ScreenStateOverlayView(state: state) {
                await load()
            }
        }
        .navigationTitle("checkIn.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .initialTask {
            await load()
        }
    }

    @ViewBuilder private var content: some View {
        Section("checkIn.admin.section.checkIn") {
            RouterLink(open: .screen(.checkIn(.init(checkIn: checkIn)))) {
                CheckInEntityView(checkIn: .init(checkIn: checkIn), hideHeader: true)
            }
        }
        .customListRowBackground()
        ModificationInfoView(modificationInfo: checkIn)
        Section("admin.section.details") {
            LabeledIdView(id: checkIn.id.rawValue.formatted())
        }
        .customListRowBackground()
        Section {
            RouterLink(
                "admin.section.reports.title",
                systemImage: "exclamationmark.bubble",
                count: checkIn.reports.count,
                open: .screen(
                    .withReportsAdmin(reports: $checkIn.map(getter: { _ in
                        checkIn.reports
                    }, setter: { reports in
                        checkIn.copyWith(reports: reports)
                    }))
                )
            )
        }
        .customListRowBackground()
        Section {
            ConfirmedDeleteButtonView(
                presenting: checkIn,
                action: deleteCheckInAsModerator,
                description: "checkIn.delete.asModerator.title",
                label: "checkIn.delete.asModerator.label \(checkIn.createdBy.preferredName)",
                isDisabled: false
            )
        }
        .customListRowBackground()
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    private func load() async {
        do {
            checkIn = try await repository.checkIn.getDetailed(id: id)
            state = .populated
        } catch {
            guard !error.isCancelled else { return }
            state = .loading
            logger.error("Failed to load detailed check for id: '\(checkIn.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteCheckInAsModerator(_ checkIn: CheckIn.Detailed) async {
        do {
            try await repository.checkIn.deleteAsModerator(id: id)
            router.removeLast()
            onDelete()
            dismiss()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete check-in as moderator'\(checkIn.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}
