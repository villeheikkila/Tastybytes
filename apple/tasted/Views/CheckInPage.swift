import SwiftUI

struct CheckInPageView: View {
    let checkIn: CheckInResponse
    @StateObject private var model = CheckInPageViewModel()

    var body: some View {
        VStack {
            CheckInCardView(checkIn: checkIn)

            List {
                ForEach(model.checkInComments, id: \.id) {
                    CommentItemView(comment: $0)
                }
            }

            Spacer()

            HStack { TextField("Comment", text: $model.comment) {
                Text("Leave a comment")
            }
            Button(action: { model.sendComment(checkInId: checkIn.id) }) {
                Image(systemName: "paperplane.fill")
            }
            }.padding(.all, 14)
        }.task {
            model.getCheckInCommets(checkInId: checkIn.id)
        }
    }
}

struct CommentItemView: View {
    let comment: CheckInCommentResponse

    var body: some View {
        HStack {
            Avatar(avatarUrl: comment.profiles.avatar_url, size: 24)
            VStack(alignment: .leading) {
                Text(comment.profiles.username).font(.system(size: 12, weight: .medium, design: .default))
                Text(comment.content)
            }
        }
    }
}

extension CheckInPageView {
    @MainActor class CheckInPageViewModel: ObservableObject {
        @Published var checkInComments = [CheckInCommentResponse]()
        @Published var comment = ""

        struct CheckInCommentRequest: Encodable {
            let content: String
            let created_by: String
            let check_in_id: Int
        }

        func sendComment(checkInId: Int) {
            print(comment)

            let sendCheckInCommentsQuery = API.supabase.database
                .from("check_in_comments")
                .insert(values: CheckInCommentRequest(content: comment, created_by: getCurrentUserId(), check_in_id: checkInId), returning: .representation)
                .select(columns: "id, content, created_at, profiles (id, username, avatar_url))")
                .limit(count: 1)
                .single()

            Task {
                let newCheckInComment = try await sendCheckInCommentsQuery.execute().decoded(to: CheckInCommentResponse.self)
                DispatchQueue.main.async {
                    self.checkInComments.append(newCheckInComment)
                }
            }
        }

        func getCheckInCommets(checkInId: Int) {
            let checkInCommentsQuery = API.supabase.database
                .from("check_in_comments")
                .select(columns: "id, content, created_at, profiles (id, username, avatar_url)")
                .eq(column: "check_in_id", value: checkInId)
                .order(column: "created_at")

            Task {
                let checkIns = try await checkInCommentsQuery.execute().decoded(to: [CheckInCommentResponse].self)
                DispatchQueue.main.async {
                    self.checkInComments = checkIns
                }
            }
        }
    }
}
