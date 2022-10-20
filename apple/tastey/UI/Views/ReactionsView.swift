import SwiftUI

struct ReactionsView: View {
    let checkInId: Int
    let currentUserId = repository.auth.getCurrentUserId()
    @State var checkInReactions: [CheckInReaction]

    init(checkInId: Int, checkInReactions: [CheckInReaction]) {
        _checkInReactions = State(initialValue: checkInReactions)
        self.checkInId = checkInId
    }

    var body: some View {
        HStack {
            ForEach(checkInReactions, id: \.id) {
                reaction in AvatarView(avatarUrl: reaction.profile.getAvatarURL(), size: 24, id: reaction.profile.id)
            }

            Button {
                if let existingReaction = checkInReactions.first(where: { $0.profile.id == currentUserId }) {
                    removeReaction(reactionId: existingReaction.id)
                } else {
                    reactToCheckIn()
                }
            } label: {
                Text("\(checkInReactions.count)")
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .foregroundColor(.primary)
                
                Image(systemName: "hand.thumbsup.fill").frame(alignment: .leading).foregroundColor(Color(.systemYellow))
            }
        }
    }

    func reactToCheckIn() {
        let newCheckInReaction = NewCheckInReaction(checkInId: checkInId)

        Task {
            let checkInReaction = try await repository.checkInReactions.insert(newCheckInReaction: newCheckInReaction)
            DispatchQueue.main.async {
                self.checkInReactions.append(checkInReaction)
            }
        }
    }

    func removeReaction(reactionId: Int) {
        Task {
            try await repository.checkInReactions.delete(id: reactionId)

            DispatchQueue.main.async {
                self.checkInReactions.removeAll(where: { $0.profile.id == currentUserId })
            }
        }
    }
}
