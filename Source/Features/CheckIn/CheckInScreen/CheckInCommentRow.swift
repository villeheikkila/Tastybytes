import Components

import Extensions
import Models
import OSLog
import Repositories
import SwiftUI
import Translation

struct CheckInCommentRowView: View {
    private let logger = Logger(category: "CheckInScreen")
    @Environment(Repository.self) private var repository
    @Environment(ProfileModel.self) private var profileModel
    @State private var showTranslator = false

    let checkIn: CheckIn.Joined
    let comment: CheckIn.Comment.Saved
    @Binding var checkInComments: [CheckIn.Comment.Saved]

    var body: some View {
        CheckInCommentView(comment: comment)
            .translationPresentation(isPresented: $showTranslator, text: comment.content)
            .contextMenu {
                if comment.profile == profileModel.profile {
                    RouterLink("labels.edit", systemImage: "pencil", open: .sheet(.editComment(checkInComment: comment, checkInComments: $checkInComments)))
                    AsyncButton("labels.delete", systemImage: "trash.fill", role: .destructive) {
                        await deleteComment(comment)
                    }
                } else {
                    ReportButton(entity: .comment(.init(comment: comment, checkIn: checkIn)))
                }
                Button("labels.translate", systemImage: "bubble.left.and.text.bubble.right") {
                    showTranslator = true
                }
                Divider()
                AdminRouterLink(open: .sheet(.checkInCommentAdmin(id: comment.id, onDelete: { id in
                    withAnimation {
                        checkInComments = checkInComments.removingWithId(id)
                    }
                })))
            }
    }

    private func deleteComment(_ comment: CheckIn.Comment.Saved) async {
        do {
            try await repository.checkInComment.deleteById(id: comment.id)
            withAnimation {
                checkInComments.remove(object: comment)
            }
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to delete comment '\(comment.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}
