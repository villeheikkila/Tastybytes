import Components
import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInCommentEditSheet: View {
    private let logger = Logger(category: "CheckInCommentEditSheet")
    @Environment(Repository.self) private var repository
    @Environment(\.dismiss) private var dismiss
    @State private var editCommentText = ""

    let checkInComment: CheckInComment
    @Binding var checkInComments: [CheckInComment]

    init(checkInComment: CheckInComment, checkInComments: Binding<[CheckInComment]>) {
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
