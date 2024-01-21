import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInCommentSection: View {
    private let logger = Logger(category: "CheckInCommentSection")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var sheet: Sheet?
    @State private var alertError: AlertError?
    @State private var showEditCommentPrompt = false
    @State private var showDeleteCommentAsModeratorConfirmation = false
    @State private var editCommentText = ""
    @State private var editComment: CheckInComment? {
        didSet {
            showEditCommentPrompt.toggle()
            editCommentText = editComment?.content ?? ""
        }
    }

    @State private var deleteAsCheckInCommentAsModerator: CheckInComment? {
        didSet {
            if deleteAsCheckInCommentAsModerator != nil {
                showDeleteCommentAsModeratorConfirmation = true
            }
        }
    }

    @Binding var checkInComments: [CheckInComment]

    var body: some View {
        ForEach(checkInComments) { comment in
            CheckInCommentView(comment: comment)
                .listRowSeparator(.hidden)
                .contextMenu {
                    if comment.profile == profileEnvironmentModel.profile {
                        Button("Edit", systemImage: "pencil") {
                            withAnimation {
                                editComment = comment
                            }
                        }
                        ProgressButton("Delete", systemImage: "trash.fill", role: .destructive) {
                            await deleteComment(comment)
                        }
                    } else {
                        ReportButton(sheet: $sheet, entity: .comment(comment))
                    }
                    Divider()
                    if profileEnvironmentModel.hasRole(.moderator) {
                        Menu {
                            if profileEnvironmentModel.hasPermission(.canDeleteComments) {
                                Button("Delete as Moderator", systemImage: "trash.fill", role: .destructive) {
                                    deleteAsCheckInCommentAsModerator = comment
                                }
                            }
                        } label: {
                            Label("Moderation", systemImage: "gear")
                                .labelStyle(.iconOnly)
                        }
                    }
                }
        }
        .confirmationDialog(
            "Are you sure you want to delete comment as a moderator?",
            isPresented: $showDeleteCommentAsModeratorConfirmation,
            titleVisibility: .visible,
            presenting: deleteAsCheckInCommentAsModerator
        ) { presenting in
            ProgressButton(
                "Delete comment from \(presenting.profile.preferredName)",
                role: .destructive,
                action: { await deleteCommentAsModerator(presenting) }
            )
        }
        .sheets(item: $sheet)
        .alert(
            "Edit Comment", isPresented: $showEditCommentPrompt,
            actions: {
                TextField("TextField", text: $editCommentText)
                Button("actions.cancel", role: .cancel, action: {})
                ProgressButton(
                    "Edit",
                    action: {
                        await updateComment()
                    }
                )
            }
        )
    }

    func updateComment() async {
        guard let editComment else { return }
        let updatedComment = CheckInComment.UpdateRequest(id: editComment.id, content: editCommentText)
        switch await repository.checkInComment.update(updateCheckInComment: updatedComment) {
        case let .success(updatedComment):
            guard let index = checkInComments.firstIndex(where: { $0.id == updatedComment.id }) else {
                return
            }
            withAnimation {
                checkInComments[index] = updatedComment
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
            logger.error("Failed to update comment \(editComment.id)'. Error: \(error) (\(#file):\(#line))")
        }
        editCommentText = ""
    }

    func deleteComment(_ comment: CheckInComment) async {
        switch await repository.checkInComment.deleteById(id: comment.id) {
        case .success:
            withAnimation {
                checkInComments.remove(object: comment)
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
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
            alertError = .init()
            logger.error("Failed to delete comment as moderator'\(comment.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}
