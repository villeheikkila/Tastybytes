import SwiftUI

struct CheckInScreenView: View {
    let checkIn: CheckIn
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject private var routeManager: RouteManager
    @EnvironmentObject private var notificationManager: NotificationManager

    var body: some View {
        VStack {
            ScrollView {
                CheckInCardView(checkIn: viewModel.checkIn ?? checkIn,
                                loadedFrom: .checkIn,
                                onDelete: {
                                    _ in routeManager.removeLast()
                                }, onUpdate: { updatedCheckIn in
                                    viewModel.setCheckIn(updatedCheckIn)
                                })
                                .task {
                                    viewModel.setCheckIn(checkIn)
                                }
                                .task {
                                    viewModel.loadCheckInComments(checkIn)
                                }

                VStack(spacing: 10) {
                    ForEach(viewModel.checkInComments.reversed(), id: \.id) {
                        comment in CommentItemView(comment: comment, content: comment.content, onDelete: { _ in
                            viewModel.deleteComment(comment)
                        }, onUpdate: {
                            updatedComment in viewModel.editComment(updateCheckInComment: updatedComment)
                        })
                    }
                }
                .padding([.leading, .trailing], 15)
            }

            HStack {
                TextField("Leave a comment!", text: $viewModel.comment)
                Button(action: { viewModel.sendComment(checkInId: checkIn.id) }) {
                    Image(systemName: "paperplane.fill")
                }.disabled(viewModel.isInvalidComment())
            }
            .padding(.all, 10)
        }
        .task {
            notificationManager.markCheckInAsRead(checkIn: checkIn)
        }
    }
}

extension CheckInScreenView {
    @MainActor class ViewModel: ObservableObject {
        @Published var checkIn: CheckIn?
        @Published var checkInComments = [CheckInComment]()
        @Published var comment = ""

        func setCheckIn(_ checkIn: CheckIn) {
            self.checkIn = checkIn
        }

        func isInvalidComment() -> Bool {
            return comment.isEmpty
        }

        func loadCheckInComments(_ checkIn: CheckIn) {
            Task {
                switch await repository.checkInComment.getByCheckInId(id: checkIn.id) {
                case let .success(checkIns):
                    await MainActor.run {
                        self.checkInComments = checkIns
                    }
                case let .failure(error):
                    print(error)
                }
            }
        }

        func deleteComment(_ comment: CheckInComment) {
            Task {
                switch await repository.checkInComment.deleteById(id: comment.id) {
                case .success():
                    await MainActor.run {
                        self.checkInComments.remove(object: comment)
                    }
                case let .failure(error):
                    print(error)
                }

            }
        }

        func sendComment(checkInId: Int) {
            let newCheckInComment = NewCheckInComment(content: comment, checkInId: checkInId)

            Task {
                let result = await repository.checkInComment.insert(newCheckInComment: newCheckInComment)
                switch result {
                case let .success(newCheckInComment):
                    await MainActor.run {
                        self.checkInComments.append(newCheckInComment)
                        self.comment = ""
                    }
                case let .failure(error):
                    print(error)
                }
            }
        }

        func editComment(updateCheckInComment: UpdateCheckInComment) {
            Task {
                switch await repository.checkInComment.update(updateCheckInComment: updateCheckInComment) {
                case let .success(updatedComment):
                    DispatchQueue.main.async {
                        if let index = self.checkInComments.firstIndex(of: updatedComment) {
                            self.checkInComments[index] = updatedComment
                        }
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

struct CommentItemView: View {
    let comment: CheckInComment
    @State var content: String
    @State var showEditCommentPrompt = false
    let onDelete: (_ commentId: Int) -> Void
    let onUpdate: (_ update: UpdateCheckInComment) -> Void

    var updateComment: () -> Void {
        return {
            guard !content.isEmpty else {
                return
            }

            let updatedComment = UpdateCheckInComment(id: comment.id, content: content)
            onUpdate(updatedComment)
            content = ""
        }
    }

    var body: some View {
        HStack {
            AvatarView(avatarUrl: comment.profile.getAvatarURL(), size: 32, id: comment.profile.id)
            VStack(alignment: .leading) {
                HStack {
                    Text(comment.profile.preferredName).font(.system(size: 12, weight: .medium, design: .default))
                    Spacer()
                    Text(comment.createdAt.formatted()).font(.system(size: 8, weight: .medium, design: .default))
                }
                Text(comment.content).font(.system(size: 14, weight: .light, design: .default))
            }
            Spacer()
        }
        .contextMenu {
            Button {
                withAnimation {
                    self.showEditCommentPrompt = true
                }
            } label: {
                Label("Edit Comment", systemImage: "pencil")
            }

            Button {
                withAnimation {
                    onDelete(comment.id)
                }
            } label: {
                Label("Delete Comment", systemImage: "trash.fill")
            }
        }
        .alert("Edit Comment", isPresented: $showEditCommentPrompt, actions: {
            TextField("TextField", text: $content)
            Button("Cancel", role: .cancel, action: {})
            Button("Edit", action: {
                updateComment()
            })
        })
    }
}
