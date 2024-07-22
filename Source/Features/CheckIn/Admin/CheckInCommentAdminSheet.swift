import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInCommentAdminSheet: View {
    private let logger = Logger(category: "CheckInCommentAdminSheet")
    @Environment(\.dismiss) private var dismiss
    @Environment(Router.self) private var router
    @Environment(Repository.self) private var repository
    @State private var state: ScreenState = .loading
    @State private var checkInComment = CheckInComment.Detailed()

    let id: CheckInComment.Id
    let onDelete: (_ comment: CheckInComment.Id) -> Void

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
                await load()
            }
        }
        .navigationTitle("comment.admin.navigationTitle")
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
            RouterLink(open: .screen(.checkIn(checkInComment.checkIn))) {
                CheckInCommentEntityView(comment: checkInComment)
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
                count: checkInComment.reports.count,
                open: .screen(
                    .withReportsAdmin(reports: $checkInComment.map(getter: { _ in
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

    private func load() async {
        do {
            checkInComment = try await repository.checkInComment.getDetailed(id: id)
            state = .populated
        } catch {
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed to load detailed check-in comment. Error: \(error) (\(#file):\(#line))")
        }
    }

    private func deleteCommentAsModerator(_ comment: CheckInComment.Detailed) async {
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
