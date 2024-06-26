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
            ProgressButton("labels.edit") {
                await updateComment()
            }
        }
    }

    func updateComment() async {
        switch await repository.checkInComment.update(updateCheckInComment: .init(id: checkInComment.id, content: editCommentText)) {
        case let .success(updatedComment):
            guard let index = checkInComments.firstIndex(where: { $0.id == updatedComment.id }) else {
                return
            }
            withAnimation {
                checkInComments[index] = updatedComment
                dismiss()
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Failed to update comment \(checkInComment.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}
