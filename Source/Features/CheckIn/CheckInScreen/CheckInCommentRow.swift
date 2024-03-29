import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
struct CheckInCommentRow: View {
    private let logger = Logger(category: "CheckInScreen")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var sheet: Sheet?
    @State private var showDeleteAsModeratorConfirmationDialog = false

    let checkIn: CheckIn
    let comment: CheckInComment
    @Binding var checkInComments: [CheckInComment]

    var body: some View {
        CheckInCommentView(comment: comment)
            .sheets(item: $sheet)
            .confirmationDialog(
                "comment.deleteAsModerator.confirmation.description",
                isPresented: $showDeleteAsModeratorConfirmationDialog,
                titleVisibility: .visible,
                presenting: comment
            ) { presenting in
                ProgressButton(
                    "comment.deleteAsModerator.confirmation.label \(presenting.profile.preferredName)",
                    role: .destructive,
                    action: { await deleteCommentAsModerator(presenting) }
                )
            }
            .contextMenu {
                if comment.profile == profileEnvironmentModel.profile {
                    Button("labels.edit", systemImage: "pencil") {
                        sheet = .editComment(checkInComment: comment, checkInComments: $checkInComments)
                    }
                    ProgressButton("labels.delete", systemImage: "trash.fill", role: .destructive) {
                        await deleteComment(comment)
                    }
                } else {
                    ReportButton(entity: .comment(.init(comment: comment, checkIn: checkIn)))
                }
                Divider()
                if profileEnvironmentModel.hasRole(.moderator) {
                    Menu {
                        if profileEnvironmentModel.hasPermission(.canDeleteComments) {
                            Button("moderation.deleteAsModerator.label", systemImage: "trash.fill", role: .destructive) {
                                showDeleteAsModeratorConfirmationDialog = true
                            }
                        }
                    } label: {
                        Label("moderation.section.title", systemImage: "gear")
                            .labelStyle(.iconOnly)
                    }
                }
            }
    }

    func deleteComment(_ comment: CheckInComment) async {
        switch await repository.checkInComment.deleteById(id: comment.id) {
        case .success:
            withAnimation {
                checkInComments.remove(object: comment)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Failed to delete comment '\(comment.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }

    func deleteCommentAsModerator(_ comment: CheckInComment) async {
        switch await repository.checkInComment.deleteAsModerator(comment: comment) {
        case .success:
            withAnimation {
                checkInComments.remove(object: comment)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Failed to delete comment as moderator'\(comment.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}
