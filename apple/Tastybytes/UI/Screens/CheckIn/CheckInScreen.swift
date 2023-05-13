import CachedAsyncImage
import SwiftUI

struct CheckInScreen: View {
  private let logger = getLogger(category: "CheckInScreen")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @State private var checkIn: CheckIn
  @State private var checkInComments = [CheckInComment]()
  @State private var showDeleteConfirmation = false
  @State private var showEditCommentPrompt = false
  @State private var commentText = ""
  @State private var editCommentText = ""
  @State private var editComment: CheckInComment? {
    didSet {
      showEditCommentPrompt.toggle()
      editCommentText = editComment?.content ?? ""
    }
  }

  init(checkIn: CheckIn) {
    _checkIn = State(wrappedValue: checkIn)
  }

  var body: some View {
    ScrollView {
      CheckInCardView(checkIn: checkIn, loadedFrom: .checkIn)
        .padding([.leading, .trailing], 8)
      commentSection
    }
    .overlay(
      MaterialOverlay(alignment: .bottom) {
        leaveCommentSection
      }
    )
    .navigationBarItems(
      trailing: Menu {
        ShareLink("Share", item: NavigatablePath.checkIn(id: checkIn.id).url)
        RouterLink(
          "Open Company",
          systemImage: "network",
          screen: .company(checkIn.product.subBrand.brand.brandOwner)
        )
        RouterLink("Open Brand", systemImage: "cart", screen: .fetchBrand(checkIn.product.subBrand.brand))
        RouterLink("Open Product", systemImage: "grid", screen: .product(checkIn.product))
        Divider()

        if profileManager.id != checkIn.profile.id {
          ReportButton(entity: .checkIn(checkIn))
        }

        if checkIn.profile.id == profileManager.id {
          RouterLink("Edit", systemImage: "pencil", sheet: .checkIn(checkIn, onUpdate: { updatedCheckIn in
            updateCheckIn(updatedCheckIn)
          }))
          Button("Delete", systemImage: "trash.fill", role: .destructive, action: { showDeleteConfirmation = true })
        }
      } label: {
        Label("Options menu", systemImage: "ellipsis")
          .labelStyle(.iconOnly)
      }
    )
    .confirmationDialog("Are you sure you want to delete check-in? The data will be permanently lost.",
                        isPresented: $showDeleteConfirmation,
                        titleVisibility: .visible,
                        presenting: checkIn)
    { presenting in
      ProgressButton(
        "Delete \(presenting.product.getDisplayName(.fullName)) check-in",
        role: .destructive,
        action: { await deleteCheckIn(presenting) }
      )
    }
    .task {
      await loadCheckInComments()
      await notificationManager.markCheckInAsRead(checkIn: checkIn)
    }
  }

  private var commentSection: some View {
    VStack(spacing: 10) {
      ForEach(checkInComments.reversed()) { comment in
        CheckInCommentView(comment: comment)
          .contextMenu {
            if comment.profile == profileManager.profile {
              Button("Edit Comment", systemImage: "pencil") {
                withAnimation {
                  editComment = comment
                }
              }
              ProgressButton("Delete Comment", systemImage: "trash.fill") {
                await deleteComment(comment)
              }
            } else {
              ReportButton(entity: .comment(comment))
            }
            Divider()
            
          }
      }
    }
    .alert("Edit Comment", isPresented: $showEditCommentPrompt, actions: {
      TextField("TextField", text: $editCommentText)
      Button("Cancel", role: .cancel, action: {})
      ProgressButton("Edit", action: {
        await updateComment()
      })
    })
    .padding([.leading, .trailing], 5)
  }

  private var leaveCommentSection: some View {
    HStack {
      TextField("Leave a comment!", text: $commentText)
      ProgressButton("Send the comment", systemImage: "paperplane.fill", action: { await sendComment() })
        .labelStyle(.iconOnly)
        .disabled(isInvalidComment())
    }
    .padding(2)
  }

  func updateCheckIn(_ checkIn: CheckIn) {
    self.checkIn = checkIn
  }

  func isInvalidComment() -> Bool {
    commentText.isEmpty
  }

  func deleteCheckIn(_ checkIn: CheckIn) async {
    switch await repository.checkIn.delete(id: checkIn.id) {
    case .success:
      feedbackManager.trigger(.notification(.success))
      router.removeLast()
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to delete check-in: \(error.localizedDescription)")
    }
  }

  func loadCheckInComments() async {
    switch await repository.checkInComment.getByCheckInId(id: checkIn.id) {
    case let .success(checkIns):
      withAnimation {
        checkInComments = checkIns
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to load check-in comments': \(error.localizedDescription)")
    }
  }

  func updateComment() async {
    guard let editComment else { return }
    let updatedComment = CheckInComment.UpdateRequest(id: editComment.id, content: editCommentText)
    switch await repository.checkInComment.update(updateCheckInComment: updatedComment) {
    case let .success(updatedComment):
      guard let index = checkInComments.firstIndex(where: { $0.id == updatedComment.id }) else { return }
      withAnimation {
        checkInComments[index] = updatedComment
      }
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to update comment \(editComment.id)': \(error.localizedDescription)")
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
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to delete comment '\(comment.id)': \(error.localizedDescription)")
    }
  }

  func sendComment() async {
    let newCheckInComment = CheckInComment.NewRequest(content: commentText, checkInId: checkIn.id)

    let result = await repository.checkInComment.insert(newCheckInComment: newCheckInComment)
    switch result {
    case let .success(newCheckInComment):
      withAnimation {
        checkInComments.append(newCheckInComment)
      }
      commentText = ""
    case let .failure(error):
      guard !error.localizedDescription.contains("cancelled") else { return }
      feedbackManager.toggle(.error(.unexpected))
      logger.error("failed to send comment: \(error.localizedDescription)")
    }
  }
}
