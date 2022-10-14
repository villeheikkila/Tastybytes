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
            let checkInCommentsQuery = API.supabase.database
                .from("check_in_comments")
                .select(columns: "id, content, created_at, profiles (id, username, avatar_url)")
                .eq(column: "check_in_id", value: checkInId)
                .order(column: "created_at")

            Task {
                let checkIns = try await checkInCommentsQuery.execute().decoded(to: [CheckInComment].self)
                DispatchQueue.main.async {
                    self.checkInComments = checkIns
                }
            }
        }

        func deleteComment(commentId: Int) {
            let deleteCheckInCommentQuery = API.supabase.database
                .from("check_in_comments")
                .delete()
                .eq(column: "id", value: commentId)

            Task {
                try await deleteCheckInCommentQuery.execute()

                DispatchQueue.main.async {
                    self.checkInComments.removeAll(where: {
                        $0.id == commentId
                    })
                }
            }
        }

        struct CheckInCommentRequest: Encodable {
            let content: String
            let created_by: String
            let check_in_id: Int
        }

        func sendComment(checkInId: Int) {
            let sendCheckInCommentsQuery = API.supabase.database
                .from("check_in_comments")
                .insert(values: CheckInCommentRequest(content: comment, created_by: getCurrentUserId(), check_in_id: checkInId), returning: .representation)
                .select(columns: "id, content, created_at, profiles (id, username, avatar_url))")
                .limit(count: 1)
                .single()

            Task {
                let newCheckInComment = try await sendCheckInCommentsQuery.execute().decoded(to: CheckInComment.self)
                DispatchQueue.main.async {
                    self.checkInComments.append(newCheckInComment)
                    self.comment = ""
                }
            }
        }

        struct EditCheckInCommentRequest: Encodable {
            let content: String
        }

        func editComment(commentId: Int, content: String) {
            let editCheckInCommentQuery = API.supabase.database
                .from("check_in_comments")
                .update(values: EditCheckInCommentRequest(content: content))
                .eq(column: "id", value: commentId)

            Task {
                try await editCheckInCommentQuery.execute()
                
                if let position = self.checkInComments.firstIndex(where: {$0.id == commentId}) {
                    self.checkInComments.remove(at: position)
                    var updatedComment = self.checkInComments[position]
                    updatedComment.content = content
                    
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
                    Avatar(avatarUrl: comment.profiles.avatarUrl, size: 32, id: comment.profiles.id)
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
