import SwiftUI

extension CheckInScreen {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "CheckInScreen")
    let client: Client
    @Published var checkIn: CheckIn
    @Published var checkInComments = [CheckInComment]()
    @Published var showDeleteConfirmation = false
    @Published var showEditCheckInSheet = false
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
      showEditCheckInSheet = false
    }

    func isInvalidComment() -> Bool {
      commentText.isEmpty
    }

    func deleteCheckIn(onDelete: @escaping () -> Void) {
      Task {
        switch await client.checkIn.delete(id: checkIn.id) {
        case .success:
          onDelete()
        case let .failure(error):
          logger.error("failed to delete check-in '\(self.checkIn.id)': \(error.localizedDescription)")
        }
      }
    }

    func loadCheckInComments() {
      Task {
        switch await client.checkInComment.getByCheckInId(id: checkIn.id) {
        case let .success(checkIns):
          withAnimation {
            self.checkInComments = checkIns
          }
        case let .failure(error):
          logger.error("faile to load check-in comments for '\(self.checkIn.id)': \(error.localizedDescription)")
        }
      }
    }

    func updateComment() {
      guard let editComment else { return }
      let updatedComment = CheckInComment.UpdateRequest(id: editComment.id, content: editCommentText)
      Task {
        switch await client.checkInComment.update(updateCheckInComment: updatedComment) {
        case let .success(updatedComment):
          guard let index = self.checkInComments.firstIndex(where: { $0.id == updatedComment.id }) else { return }
          withAnimation {
            self.checkInComments[index] = updatedComment
          }
        case let .failure(error):
          logger
            .error(
              """
              failed to update comment \(editComment.id) with text\
                '\(self.editCommentText)': \(error.localizedDescription)
              """
            )
        }
      }

      editCommentText = ""
    }

    func deleteComment(_ comment: CheckInComment) {
      Task {
        switch await client.checkInComment.deleteById(id: comment.id) {
        case .success:
          withAnimation {
            self.checkInComments.remove(object: comment)
          }
        case let .failure(error):
          logger.error("failed to delete comment '\(comment.id)': \(error.localizedDescription)")
        }
      }
    }

    func sendComment() {
      let newCheckInComment = CheckInComment.NewRequest(content: commentText, checkInId: checkIn.id)

      Task {
        let result = await client.checkInComment.insert(newCheckInComment: newCheckInComment)
        switch result {
        case let .success(newCheckInComment):
          withAnimation {
            self.checkInComments.append(newCheckInComment)
          }
          self.commentText = ""
        case let .failure(error):
          logger
            .error(
              """
              failed to send comment '\(self.commentText)' to\
                            check-in '\(self.checkIn.id)': \(error.localizedDescription)
              """
            )
        }
      }
    }
  }
}
