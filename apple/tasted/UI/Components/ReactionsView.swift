import SwiftUI

struct ReactionsView: View {
    let checkInId: Int
    @State var checkInReactions: [CheckInReaction]

    init(checkInId: Int, checkInReactions: [CheckInReaction]) {
        _checkInReactions = State(initialValue: checkInReactions)
        self.checkInId = checkInId
    }

    var body: some View {
        HStack {
            ForEach(checkInReactions, id: \.id) {
                reaction in Avatar(avatarUrl: reaction.profiles.avatarUrl, size: 24, id: reaction.profiles.id)
            }

            Button {
                if let existingReaction = checkInReactions.first(where: { $0.createdBy == getCurrentUserIdUUID() }) {
                    removeReaction(reactionId: existingReaction.id)
                } else {
                    reactToCheckIn()
                }
            } label: {
                Text("\(checkInReactions.count)").font(.system(size: 14, weight: .bold, design: .default)).foregroundColor(.primary)
                Image(systemName: "hand.thumbsup.fill").frame(alignment: .leading).foregroundColor(Color(.systemYellow))
            }
        }
    }

    func reactToCheckIn() {
        let query = API.supabase.database.from("check_in_reactions")
            .insert(values: CheckInReactionRequest(check_in_id: checkInId, created_by: getCurrentUserIdUUID()), returning: .representation)
            .select(columns: "id, created_by, profiles (id, username, avatar_url)")
            .limit(count: 1)
            .single()

        Task {
            let checkInReaction = try await query.execute().decoded(to: CheckInReaction.self)
            DispatchQueue.main.async {
                self.checkInReactions.append(checkInReaction)
            }
        }
    }

    func removeReaction(reactionId: Int) {
        let query = API.supabase.database.from("check_in_reactions")
            .delete().eq(column: "id", value: reactionId)

        Task {
            try await query.execute()

            DispatchQueue.main.async {
                self.checkInReactions.removeAll(where: { $0.createdBy == getCurrentUserIdUUID() })
            }
        }
    }

    struct CheckInReactionRequest: Encodable {
        let check_in_id: Int
        let created_by: UUID
    }
}
