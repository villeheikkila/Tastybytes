import SwiftUI

extension CheckInScreen {
  @MainActor
  class ViewModel: ObservableObject {
    private let logger = getLogger(category: "CheckInScreen")
    let client: Client
    @Published var checkIn: CheckIn
    @Published var checkInComments = [CheckInComment]()
    @Published var showDeleteConfirmation = false
    @Published var showEditCommentPrompt = false
    @Published var commentText = ""
    @Published var editCommentText = ""
    @Published var editComment: CheckInComment? {
      didSet {
        showEditCommentPrompt.toggle()
        editCommentText = editComment?.content ?? ""
      }
    }

    init(_ client: Client, checkIn: CheckIn) {
      self.checkIn = checkIn
      self.client = client
    }

    func updateCheckIn(_ checkIn: CheckIn) {
      self.checkIn = checkIn
    }

    func isInvalidComment() -> Bool {
      commentText.isEmpty
    }

    func deleteCheckIn(onDelete: @escaping () -> Void) async {
      switch await client.checkIn.delete(id: checkIn.id) {
      case .success:
        onDelete()
      case let .failure(error):
        logger.error("failed to delete check-in: \(error.localizedDescription)")
      }
    }

    func loadCheckInComments() async {
      switch await client.checkInComment.getByCheckInId(id: checkIn.id) {
      case let .success(checkIns):
        withAnimation {
          self.checkInComments = checkIns
        }
      case let .failure(error):
        logger.error("failed to load check-in comments': \(error.localizedDescription)")
      }
    }

    func updateComment() async {
      guard let editComment else { return }
      let updatedComment = CheckInComment.UpdateRequest(id: editComment.id, content: editCommentText)
      switch await client.checkInComment.update(updateCheckInComment: updatedComment) {
      case let .success(updatedComment):
        guard let index = checkInComments.firstIndex(where: { $0.id == updatedComment.id }) else { return }
        withAnimation {
          self.checkInComments[index] = updatedComment
        }
      case let .failure(error):
        logger.error("failed to update comment \(editComment.id)': \(error.localizedDescription)")
      }
      editCommentText = ""
    }

    func deleteComment(_ comment: CheckInComment) async {
      switch await client.checkInComment.deleteById(id: comment.id) {
      case .success:
        withAnimation {
          self.checkInComments.remove(object: comment)
        }
      case let .failure(error):
        logger.error("failed to delete comment '\(comment.id)': \(error.localizedDescription)")
      }
    }

    func sendComment() async {
      let newCheckInComment = CheckInComment.NewRequest(content: commentText, checkInId: checkIn.id)

      let result = await client.checkInComment.insert(newCheckInComment: newCheckInComment)
      switch result {
      case let .success(newCheckInComment):
        withAnimation {
          self.checkInComments.append(newCheckInComment)
        }
        commentText = ""
      case let .failure(error):
        logger.error("failed to send comment: \(error.localizedDescription)")
      }
    }
  }
}
