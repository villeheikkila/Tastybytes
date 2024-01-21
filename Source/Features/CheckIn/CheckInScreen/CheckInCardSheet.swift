import Components
import Models
import OSLog
import Repositories
import SwiftUI

@MainActor
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
        NavigationStack {
            Form {
                TextField("TextField", text: $editCommentText)
            }
            .scrollBounceBehavior(.basedOnSize)
            .navigationTitle("Edit Comment")
            .toolbar {
                toolbarContent
            }
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .cancellationAction) {
            CloseButtonView {
                dismiss()
            }
        }
        ToolbarItemGroup(placement: .primaryAction) {
            ProgressButton("Edit") {
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
