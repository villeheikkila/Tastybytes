import CachedAsyncImage
import SwiftUI

struct CheckInScreen: View {
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
      MaterialOverlay(alignment: .bottom) {
        leaveCommentSection
      }
    )
    .navigationBarItems(
      trailing: Menu {
        ShareLink("Share", item: NavigatablePath.checkIn(id: viewModel.checkIn.id).url)
        RouterLink(
          "Open Company",
          systemImage: "network",
          screen: .company(viewModel.checkIn.product.subBrand.brand.brandOwner)
        )
        RouterLink("Open Brand", systemImage: "cart", screen: .fetchBrand(viewModel.checkIn.product.subBrand.brand))
        RouterLink("Open Product", systemImage: "grid", screen: .product(viewModel.checkIn.product))
        Divider()

        if profileManager.getId() != viewModel.checkIn.profile.id {
          ReportButton(entity: .checkIn(viewModel.checkIn))
        }

        if viewModel.checkIn.profile.id == profileManager.getId() {
          RouterLink("Edit", systemImage: "pencil", sheet: .checkIn(viewModel.checkIn, onUpdate: { updatedCheckIn in
            viewModel.updateCheckIn(updatedCheckIn)
          }))
          Button("Delete", systemImage: "trash.fill", role: .destructive, action: { viewModel.showDeleteConfirmation = true })
        }
      } label: {
        Label("Options menu", systemImage: "ellipsis")
          .labelStyle(.iconOnly)
      }
    )
    .confirmationDialog("Are you sure you want to delete check-in? The data will be permanently lost.",
                        isPresented: $viewModel.showDeleteConfirmation,
                        titleVisibility: .visible,
                        presenting: viewModel.checkIn)
    { presenting in
      ProgressButton(
        "Delete \(presenting.product.getDisplayName(.fullName)) check-in",
        role: .destructive,
        action: {
          await viewModel.deleteCheckIn(onDelete: {
            hapticManager.trigger(.notification(.success))
            router.removeLast()
          })
        }
      )
    }
    .task {
      await viewModel.loadCheckInComments()
      await notificationManager.markCheckInAsRead(checkIn: viewModel.checkIn)
    }
  }

  private var commentSection: some View {
    VStack(spacing: 10) {
      ForEach(viewModel.checkInComments.reversed()) { comment in
        CheckInCommentView(comment: comment)
          .contextMenu {
            if comment.profile == profileManager.getProfile() {
              Button {
                withAnimation {
                  viewModel.editComment = comment
                }
              } label: {
                Label("Edit Comment", systemImage: "pencil")
              }

              ProgressButton {
                await viewModel.deleteComment(comment)
              } label: {
                Label("Delete Comment", systemImage: "trash.fill")
              }
            } else {
              ReportButton(entity: .comment(comment))
            }
          }
      }
    }
    .alert("Edit Comment", isPresented: $viewModel.showEditCommentPrompt, actions: {
      TextField("TextField", text: $viewModel.editCommentText)
      Button("Cancel", role: .cancel, action: {})
      ProgressButton("Edit", action: {
        await viewModel.updateComment()
      })
    })
    .padding([.leading, .trailing], 5)
  }

  private var leaveCommentSection: some View {
    HStack {
      TextField("Leave a comment!", text: $viewModel.commentText)
      ProgressButton("Send the comment", systemImage: "paperplane.fill", action: { await viewModel.sendComment() })
        .labelStyle(.iconOnly)
        .disabled(viewModel.isInvalidComment())
    }
    .padding(2)
  }
}
