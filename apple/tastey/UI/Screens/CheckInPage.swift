import SwiftUI

struct CheckInPageView: View {
    let checkIn: CheckIn
    @StateObject private var model = CheckInPageViewModel()

    var body: some View {
        VStack {
            CheckInCardView(checkIn: checkIn)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(model.checkInComments.reversed(), id: \.id) {
                        comment in CommentItemView(comment: comment, content: comment.content, deleteComment: { id in
                            model.deleteComment(commentId: id)
                        }, editComment: {
                            id, content in model.editComment(commentId: id, content: content)
                        })
                    }
                }.padding(.leading, 15)
                    .padding(.trailing, 15)
            }

            HStack {
                TextField("Leave a comment!", text: $model.comment)
                Button(action: { model.sendComment(checkInId: checkIn.id) }) {
                    Image(systemName: "paperplane.fill")
                }
            }.padding(.all, 10)
        }.task {
            model.getCheckInCommets(checkInId: checkIn.id)
        }
    }
}

extension CheckInPageView {
    @MainActor class CheckInPageViewModel: ObservableObject {
        @Published var checkInComments = [CheckInComment]()
        @Published var comment = ""

        func getCheckInCommets(checkInId: Int) {
            Task {
                let checkIns = try await SupabaseCheckInCommentRepository().loadByCheckInId(id: checkInId)
                DispatchQueue.main.async {
                    self.checkInComments = checkIns
                }
            }
        }

        func deleteComment(commentId: Int) {
            Task {
                try await SupabaseCheckInCommentRepository().deleteById(id: commentId)
                DispatchQueue.main.async {
                    self.checkInComments.removeAll(where: {
                        $0.id == commentId
                    })
                }
            }
        }

        func sendComment(checkInId: Int) {
            let newCheckInComment = NewCheckInComment(content: comment, createdBy: SupabaseAuthRepository().getCurrentUserId(), checkInId: checkInId)

            Task {
                let newCheckInComment = try await SupabaseCheckInCommentRepository().insert(newCheckInComment: newCheckInComment)
                DispatchQueue.main.async {
                    self.checkInComments.append(newCheckInComment)
                    self.comment = ""
                }
            }
        }

        func editComment(commentId: Int, content: String) {
            let updateCheckInComment = UpdateCheckInComment(content: comment)

            Task {
                let updated = try await SupabaseCheckInCommentRepository().update(id: commentId, updateCheckInComment: updateCheckInComment)

                if let position = self.checkInComments.firstIndex(where: { $0.id == commentId }) {
                    self.checkInComments.remove(at: position)
                    var updatedComment = self.checkInComments[position]
                    updatedComment.content = updated.content

                    DispatchQueue.main.async {
                        self.checkInComments.insert(contentsOf: [updatedComment], at: position)
                    }
                }
            }
        }
    }
}

struct CommentItemView: View {
    let comment: CheckInComment
    @State var content: String
    let deleteComment: (_ commentId: Int) -> Void
    let editComment: (_ commentId: Int, _ content: String) -> Void

    var body: some View {
        CollapsibleView(
            content: {
                HStack {
                    Avatar(avatarUrl: comment.profiles.getAvatarURL(), size: 32, id: comment.profiles.id)
                    VStack(alignment: .leading) {
                        Text(comment.profiles.username).font(.system(size: 12, weight: .medium, design: .default))
                        Text(comment.content).font(.system(size: 14, weight: .light, design: .default))
                    }
                    Text(comment.createdAt)
                }
            },
            expandedContent: {
                HStack(spacing: 10) {
                    EditCommentPropmptView(content: comment.content, editComment: {
                        editedComment in
                        editComment(comment.id, editedComment)
                    })

                    Button(action: {
                        deleteComment(comment.id)
                    }) {
                        Image(systemName: "trash.fill")
                            .imageScale(.large)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        )
        .frame(maxWidth: .infinity)
    }
}

struct EditCommentPropmptView: View {
    @State private var presentAlert = false
    @State var content: String
    let editComment: (_ content: String) -> Void

    var body: some View {
        Button(action: {
            presentAlert = true

        }) {
            Image(systemName: "pencil")
                .imageScale(.large)
        }
        .alert("Edit Comment", isPresented: $presentAlert, actions: {
            TextField("TextField", text: $content)
            Button("Cancel", role: .cancel, action: {})
            Button("Edit", action: {
                editComment(content)
            })
        })
    }
}
