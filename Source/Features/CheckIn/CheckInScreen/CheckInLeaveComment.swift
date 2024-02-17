import Components
import Models
import OSLog
import Repositories
import SwiftUI

struct CheckInLeaveComment: View {
    private let logger = Logger(category: "CheckInLeaveComment")
    @Environment(Repository.self) private var repository
    @State private var commentText: String = ""
    let checkIn: CheckIn
    @Binding var checkInComments: [CheckInComment]
    @FocusState var focusedField: Focusable?

    var body: some View {
        HStack {
            Spacer()
            VStack {
                HStack {
                    TextField("comment.textField.placeholder", text: $commentText)
                        .focused($focusedField, equals: .checkInComment)
                    ProgressButton(
                        "comment.textField.send.label", systemImage: "paperplane.fill", action: { await sendComment() }
                    )
                    .labelStyle(.iconOnly)
                    .disabled(commentText.isEmpty)
                }
                .padding(2)
            }
            .padding(.vertical, 10)
            Spacer()
        }
        .background(.ultraThinMaterial)
    }

    func sendComment() async {
        let newCheckInComment = CheckInComment.NewRequest(content: commentText, checkInId: checkIn.id)

        let result = await repository.checkInComment.insert(newCheckInComment: newCheckInComment)
        switch result {
        case let .success(newCheckInComment):
            withAnimation {
                checkInComments.insert(newCheckInComment, at: 0)
                commentText = ""
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            logger.error("Failed to send comment. Error: \(error) (\(#file):\(#line))")
        }
    }

    enum Focusable {
        case checkInComment
    }
}
