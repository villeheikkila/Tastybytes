import CachedAsyncImage
import SwiftUI

struct CheckInScreenView: View {
  @StateObject private var viewModel: ViewModel
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var notificationManager: NotificationManager
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var hapticManager: HapticManager

  init(_ client: Client, checkIn: CheckIn) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, checkIn: checkIn))
  }

  var body: some View {
    ScrollView {
      CheckInCardView(client: viewModel.client, checkIn: viewModel.checkIn, loadedFrom: .checkIn)
      commentSection
    }
    .overlay(
      BottomOverlay {
        leaveCommentSection
      }
    )
    .sheet(isPresented: $viewModel.showEditCheckInSheet) {
      NavigationStack {
        CheckInSheetView(viewModel.client, checkIn: viewModel.checkIn, onUpdate: { updatedCheckIn in
          viewModel.updateCheckIn(updatedCheckIn)
        })
      }
    }
    .navigationBarItems(
      trailing: Menu {
        ShareLink("Share", item: NavigatablePath.checkIn(id: viewModel.checkIn.id).url)

        Divider()

        if viewModel.checkIn.profile.id == profileManager.getId() {
          Button(action: { viewModel.showEditCheckInSheet = true }, label: {
            Label("Edit", systemImage: "pencil")
          })
          Button(role: .destructive, action: { viewModel.showDeleteConfirmation = true }, label: {
            Label("Delete", systemImage: "trash.fill")
          })
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
          viewModel.deleteCheckIn(onDelete: {
            hapticManager.trigger(of: .notification(.success))
            router.removeLast()
          })
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
      ForEach(viewModel.checkInComments.reversed(), id: \.id) { comment in
        CheckInCommentView(comment: comment)
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
    HStack {
      TextField("Leave a comment!", text: $viewModel.commentText)
      Button(action: { viewModel.sendComment() }, label: {
        Image(systemName: "paperplane.fill")
      })
      .disabled(viewModel.isInvalidComment())
    }
    .padding(2)
  }
}
