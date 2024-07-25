import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInAdminSheet: View {
    typealias OnUpdateCallback = (CheckIn.Detailed) -> Void
    typealias OnDeleteCallback = (CheckIn.Id) -> Void

    enum Open {
        case report(Report.Id)
    }

    private let logger = Logger(category: "CheckInAdminSheet")
    @Environment(\.dismiss) private var dismiss
    @Environment(Router.self) private var router
    @Environment(Repository.self) private var repository
    @State private var state: ScreenState = .loading
    @State private var checkIn = CheckIn.Detailed()

    let id: CheckIn.Id
    let open: Open?
    let onUpdate: OnUpdateCallback
    let onDelete: OnDeleteCallback

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
                await initialize()
            }
        }
        .navigationTitle("checkIn.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .initialTask {
            await initialize()
        }
    }

    @ViewBuilder private var content: some View {
        Section("checkIn.admin.section.checkIn") {
            RouterLink(open: .screen(.checkIn(checkIn.id))) {
                CheckInEntityView(checkIn: .init(checkIn: checkIn), hideHeader: true)
            }
        }
        .customListRowBackground()
        ModificationInfoView(modificationInfo: checkIn)
        Section("admin.section.details") {
            LabeledIdView(id: checkIn.id.rawValue.formatted())
            LabeledContent("checkIn.label") {
                RouterLink(
                    checkIn.product.formatted(.fullName),
                    open: .sheet(.productAdmin(id: checkIn.product.id, onUpdate: { product in
                        checkIn = checkIn.copyWith(product: .init(product: product))
                        onUpdate(checkIn)
                    }, onDelete: { _ in
                        dismiss()
                        onDelete(checkIn.id)
                    }))
                )
            }
        }
        .customListRowBackground()
        Section {
            RouterLink(
                "admin.section.reports.title",
                systemImage: "exclamationmark.bubble",
                badge: checkIn.reports.count,
                open: .screen(
                    .reports(reports: $checkIn.map(getter: { _ in
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

    private func initialize() async {
        do {
            checkIn = try await repository.checkIn.getDetailed(id: id)
            state = .populated
            if let open {
                switch open {
                case let .report(id):
                    router.open(.screen(
                        .reports(reports: $checkIn.map(getter: { profile in
                            profile.reports
                        }, setter: { reports in
                            checkIn.copyWith(reports: reports)
                        }), initialReport: id)))
                }
            }
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
            onDelete(checkIn.id)
            dismiss()
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete check-in as moderator'\(checkIn.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}
