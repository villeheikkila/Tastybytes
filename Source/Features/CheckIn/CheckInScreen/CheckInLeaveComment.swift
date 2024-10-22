import Components
import Models
import Logging
import Repositories
import SwiftUI

struct CheckInLeaveComment: View {
    private let logger = Logger(label: "CheckInLeaveComment")
    @Environment(Repository.self) private var repository
    @State private var commentText: String = ""

    let checkIn: CheckIn.Joined
    @Binding var checkInComments: [CheckIn.Comment.Saved]
    @FocusState var focusedField: Focusable?
    let onSubmitted: (_ comment: CheckIn.Comment.Saved) async -> Void

    var body: some View {
        HStack(alignment: .center) {
            TextField("comment.textField.placeholder", text: $commentText, axis: .vertical)
                .focused($focusedField, equals: .checkInComment)
            AsyncButton(
                "comment.textField.send.label", systemImage: "paperplane.fill", action: { await sendComment() }
            )
            .labelStyle(.iconOnly)
            .disabled(commentText.isEmpty)
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    private func sendComment() async {
        do {
            let newCheckInComment = try await repository.checkInComment.insert(newCheckInComment: .init(content: commentText, checkInId: checkIn.id))
            withAnimation {
                checkInComments.insert(newCheckInComment, at: 0)
                commentText = ""
            }
            await onSubmitted(newCheckInComment)
        } catch {
            guard !error.isCancelled else { return }
            logger.error("Failed to send comment. Error: \(error) (\(#file):\(#line))")
        }
    }

    enum Focusable {
        case checkInComment
    }
}
