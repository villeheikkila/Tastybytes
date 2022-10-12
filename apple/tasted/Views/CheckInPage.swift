import SwiftUI

struct CheckInPageView: View {
    let checkIn: CheckInResponse
    @StateObject private var model = CheckInPageViewModel()

        
    var body: some View {
        ScrollView {
            CheckInCardView(checkIn: checkIn)
        }.task {
            model.getCheckInCommets(checkInId: checkIn.id )
        }
    }
}

extension CheckInPageView {
    @MainActor class CheckInPageViewModel: ObservableObject {
        @Published var checkInComments = [CheckInCommentResponse]()

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
