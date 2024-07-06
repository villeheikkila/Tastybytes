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

    let checkIn: CheckIn
    let comment: CheckInComment
    let onDelete: (_ comment: CheckInComment) -> Void

    var body: some View {
        Form {
            content
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("comment.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ViewBuilder private var content: some View {
        Section("checkIn.admin.section.checkIn") {
            RouterLink(open: .screen(.checkIn(checkIn))) {
                CheckInCommentEntityView(comment: comment)
            }
        }
        CreationInfoSection(createdBy: comment.profile, createdAt: comment.createdAt)
        Section("admin.section.details") {
            LabeledIdView(id: comment.id.formatted())
        }
        Section {
            RouterLink("admin.section.reports.title", systemImage: "exclamationmark.bubble", open: .screen(.reports(.comment(comment.id))))
        }
        Section {
            ConfirmedDeleteButtonView(presenting: comment, action: deleteCommentAsModerator, description: "comment.deleteAsModerator.confirmation.description", label: "comment.deleteAsModerator.confirmation.label \(comment.profile.preferredName)", isDisabled: false)
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    func deleteCommentAsModerator(_ comment: CheckInComment) async {
        switch await repository.checkInComment.deleteAsModerator(comment: comment) {
        case .success:
            onDelete(comment)
            dismiss()
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Failed to delete comment as moderator'\(comment.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}
