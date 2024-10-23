import Components
import Logging
import Models
import Repositories
import SwiftUI

struct CheckInCommentEditSheet: View {
    private let logger = Logger(label: "CheckInCommentEditSheet")
    @Environment(Repository.self) private var repository
    @Environment(\.dismiss) private var dismiss
    @State private var editCommentText = ""

    let checkInComment: CheckIn.Comment.Saved
    @Binding var checkInComments: [CheckIn.Comment.Saved]

    init(checkInComment: CheckIn.Comment.Saved, checkInComments: Binding<[CheckIn.Comment.Saved]>) {
        _editCommentText = State(initialValue: checkInComment.content)
        _checkInComments = checkInComments
        self.checkInComment = checkInComment
    }

    var body: some View {
        Form {
            TextField("comment.edit.placeholder", text: $editCommentText)
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationTitle("comment.edit.navigationTitle")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
        ToolbarItemGroup(placement: .primaryAction) {
            AsyncButton("labels.edit") {
                await updateComment()
            }
        }
    }

    private func updateComment() async {
        do {
            let updatedComment = try await repository.checkInComment.update(updateCheckInComment: .init(id: checkInComment.id, content: editCommentText))
            guard let index = checkInComments.firstIndex(where: { $0.id == updatedComment.id }) else {
                return
            }
            withAnimation {
                checkInComments[index] = updatedComment
                dismiss()
            }
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to update comment \(checkInComment.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}
