import SwiftUI

struct ReactionsView: View {
    let checkIn: CheckIn
    let currentUserId = repository.auth.getCurrentUserId()
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        HStack {
            ForEach(viewModel.checkInReactions, id: \.id) {
                reaction in AvatarView(avatarUrl: reaction.profile.getAvatarURL(), size: 24, id: reaction.profile.id)
            }

            Button {
                if let existingReaction = viewModel.checkInReactions.first(where: { $0.profile.id == currentUserId }) {
                    viewModel.removeReaction(reactionId: existingReaction.id)
                } else {
                    viewModel.reactToCheckIn(checkIn)
                }
            } label: {
                Text("\(viewModel.checkInReactions.count)")
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .foregroundColor(.primary)

                Image(systemName: "hand.thumbsup.fill")
                    .frame(height: 24, alignment: .leading)
                    .foregroundColor(Color(.systemYellow))
            }
        }.task {
            viewModel.loadInitialReactions(checkIn)
        }
    }
}

extension ReactionsView {
    @MainActor class ViewModel: ObservableObject {
        @Published var checkInReactions = [CheckInReaction]()

        func loadInitialReactions(_ checkIn: CheckIn) {
            DispatchQueue.main.async {
                self.checkInReactions = checkIn.checkInReactions
            }
        }

        func reactToCheckIn(_ checkIn: CheckIn) {
            let newCheckInReaction = NewCheckInReaction(checkInId: checkIn.id)

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
                    self.checkInReactions.removeAll(where: { $0.id == reactionId })
                }
            }
        }
    }
}
