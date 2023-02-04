import CachedAsyncImage
import SwiftUI

struct CheckInScreenView: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var profileManager: ProfileManager

  init(checkIn: CheckIn) {
    _viewModel = StateObject(wrappedValue: ViewModel(checkIn: checkIn))
  }

  var body: some View {
    ScrollView {
      CheckInCardView(checkIn: viewModel.checkIn, loadedFrom: .checkIn)
      commentSection
    }
    .overlay(
      leaveCommentSection
    )
    .sheet(isPresented: $viewModel.showEditCheckInSheet) {
      NavigationStack {
        CheckInSheetView(checkIn: viewModel.checkIn, onUpdate: {
          updatedCheckIn in
          viewModel.updateCheckIn(updatedCheckIn)
        })
      }
    }
    .navigationBarItems(
      trailing: Menu {
        ShareLink("Share", item: NavigatablePath.checkIn(id: viewModel.checkIn.id).url)

        Divider()

        if viewModel.checkIn.profile.id == profileManager.getId() {
          Button(action: {
            viewModel.showEditCheckInSheet = true
          }) {
            Label("Edit", systemImage: "pencil")
          }

          Button(action: {
            viewModel.showDeleteConfirmation = true
          }) {
            Label("Delete", systemImage: "trash.fill")
          }
        }
      } label: {
        Image(systemName: "ellipsis")
      }
    )
    .confirmationDialog("Delete Check-in Confirmation",
                        isPresented: $viewModel.showDeleteConfirmation,
                        presenting: viewModel.checkIn) { presenting in
      Button(
        "Delete the check-in for \(presenting.product.getDisplayName(.fullName))",
        role: .destructive,
        action: {
          viewModel.deleteCheckIn(checkIn: presenting, onDelete: { router.removeLast() })
        }
      )
    }
    .task {
      viewModel.loadCheckInComments()
      notificationManager.markCheckInAsRead(checkIn: viewModel.checkIn)
    }
  }

  private var commentSection: some View {
    VStack(spacing: 10) {
      ForEach(viewModel.checkInComments.reversed(), id: \.id) {
        comment in
        CheckInCommenView(comment: comment)
          .contextMenu {
            Button {
              withAnimation {
                viewModel.editComment = comment
              }
            } label: {
              Label("Edit Comment", systemImage: "pencil")
            }

            Button {
              withAnimation {
                viewModel.deleteComment(comment)
              }
            } label: {
              Label("Delete Comment", systemImage: "trash.fill")
            }
          }
      }
    }
    .alert("Edit Comment", isPresented: $viewModel.showEditCommentPrompt, actions: {
      TextField("TextField", text: $viewModel.editCommentText)
      Button("Cancel", role: .cancel, action: {})
      Button("Edit", action: {
        viewModel.updateComment()
      })
    })
    .padding([.leading, .trailing], 5)
  }

  private var leaveCommentSection: some View {
    VStack {
      Spacer()
      HStack {
        TextField("Leave a comment!", text: $viewModel.commentText)
        Button(action: { viewModel.sendComment() }) {
          Image(systemName: "paperplane.fill")
        }
        .disabled(viewModel.isInvalidComment())
      }
      .padding(.all, 10)
      .background(Color(.systemBackground))
      .cornerRadius(8, corners: [.topLeft, .topRight])
    }
  }

  struct CheckInCommenView: View {
    let comment: CheckInComment

    var body: some View {
      HStack {
        AvatarView(avatarUrl: comment.profile.getAvatarURL(), size: 32, id: comment.profile.id)
        VStack(alignment: .leading) {
          HStack {
            Text(comment.profile.preferredName).font(.system(size: 12, weight: .medium, design: .default))
            Spacer()
            Text(comment.createdAt.relativeTime()).font(.system(size: 8, weight: .medium, design: .default))
          }
          Text(comment.content).font(.system(size: 14, weight: .light, design: .default))
        }
        Spacer()
      }
    }
  }
}

extension CheckInScreenView {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "CheckInScreenView")
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

    init(checkIn: CheckIn) {
      self.checkIn = checkIn
    }

    func updateCheckIn(_ checkIn: CheckIn) {
      self.checkIn = checkIn
      showEditCheckInSheet = false
    }

    func isInvalidComment() -> Bool {
      commentText.isEmpty
    }

    func deleteCheckIn(checkIn: CheckIn, onDelete: @escaping () -> Void) {
      Task {
        switch await repository.checkIn.delete(id: checkIn.id) {
        case .success:
          onDelete()
        case let .failure(error):
          print(error)
        }
      }
    }

    func loadCheckInComments() {
      Task {
        switch await repository.checkInComment.getByCheckInId(id: checkIn.id) {
        case let .success(checkIns):
          withAnimation {
            self.checkInComments = checkIns
          }
        case let .failure(error):
          print(error)
        }
      }
    }

    func updateComment() {
      if let editComment {
        let updatedComment = CheckInComment.UpdateRequest(id: editComment.id, content: editCommentText)
        Task {
          switch await repository.checkInComment.update(updateCheckInComment: updatedComment) {
          case let .success(updatedComment):
            withAnimation {
              if let index = self.checkInComments.firstIndex(where: { $0.id == updatedComment.id }) {
                self.checkInComments[index] = updatedComment
              }
            }
          case let .failure(error):
            print(error.localizedDescription)
          }
        }

        editCommentText = ""
      }
    }

    func deleteComment(_ comment: CheckInComment) {
      Task {
        switch await repository.checkInComment.deleteById(id: comment.id) {
        case .success:
          withAnimation {
            self.checkInComments.remove(object: comment)
          }
        case let .failure(error):
          print(error)
        }
      }
    }

    func sendComment() {
      let newCheckInComment = CheckInComment.NewRequest(content: commentText, checkInId: checkIn.id)

      Task {
        let result = await repository.checkInComment.insert(newCheckInComment: newCheckInComment)
        switch result {
        case let .success(newCheckInComment):
          withAnimation {
            self.checkInComments.append(newCheckInComment)
          }
          self.commentText = ""
        case let .failure(error):
          print(error)
        }
      }
    }
  }
}
