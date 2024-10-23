
import Logging
import Models
import Repositories
import SwiftUI

struct CheckInCommentAdminSheet: View {
    typealias OnDeleteCallback = (_ comment: CheckIn.Comment.Id) -> Void

    enum Open {
        case report(Report.Id)
    }

    private let logger = Logger(label: "CheckInCommentAdminSheet")
    @Environment(\.dismiss) private var dismiss
    @Environment(Router.self) private var router
    @Environment(Repository.self) private var repository
    @State private var state: ScreenState = .loading
    @State private var checkInComment = CheckIn.Comment.Detailed()

    let id: CheckIn.Comment.Id
    let open: Open?
    let onDelete: OnDeleteCallback

    var body: some View {
        Form {
            if state.isPopulated {
                content
            }
        }
        .scrollContentBackground(.hidden)
        .animation(.default, value: checkInComment)
        .overlay {
            ScreenStateOverlayView(state: state) {
                await initialize()
            }
        }
        .navigationTitle("comment.admin.navigationTitle")
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
            RouterLink(open: .screen(.checkIn(checkInComment.checkIn.id))) {
                CheckInCommentView(comment: checkInComment)
            }
        }
        .customListRowBackground()
        CreationInfoSection(createdBy: checkInComment.profile, createdAt: checkInComment.createdAt)
        Section("admin.section.details") {
            LabeledIdView(id: checkInComment.id.rawValue.formatted())
        }
        .customListRowBackground()
        Section {
            RouterLink(
                "admin.section.reports.title",
                systemImage: "exclamationmark.bubble",
                badge: checkInComment.reports.count,
                open: .screen(
                    .reports(reports: $checkInComment.map(getter: { _ in
                        checkInComment.reports
                    }, setter: { reports in
                        checkInComment.copyWith(reports: reports)
                    }))
                )
            )
        }
        .customListRowBackground()
        Section {
            ConfirmedDeleteButtonView(presenting: checkInComment, action: deleteCommentAsModerator, description: "comment.deleteAsModerator.confirmation.description", label: "comment.deleteAsModerator.confirmation.label \(checkInComment.profile.preferredName)", isDisabled: false)
        }
        .customListRowBackground()
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    private func initialize() async {
        do {
            checkInComment = try await repository.checkInComment.getDetailed(id: id)
            state = .populated
            if let open {
                switch open {
                case let .report(id):
                    router.open(.screen(
                        .reports(reports: $checkInComment.map(getter: { profile in
                            profile.reports
                        }, setter: { reports in
                            checkInComment.copyWith(reports: reports)
                        }), initialReport: id)))
                }
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .error(error)
            logger.error("Failed to load detailed check-in comment. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteCommentAsModerator(_ comment: CheckIn.Comment.Detailed) async {
        do {
            try await repository.checkInComment.deleteAsModerator(id: comment.id)
            onDelete(id)
            dismiss()
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to delete comment as moderator'\(comment.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}
