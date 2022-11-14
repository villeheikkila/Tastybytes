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
            checkInReactions = checkIn.checkInReactions
        }

        func reactToCheckIn(_ checkIn: CheckIn) {
            Task {
                switch await repository.checkInReactions.insert(newCheckInReaction: NewCheckInReaction(checkInId: checkIn.id)) {
                case let .success(checkInReaction):
                    await MainActor.run {
                        self.checkInReactions.append(checkInReaction)
                    }
                case let .failure(error):
                    print(error)
                }
            }
        }

        func removeReaction(reactionId: Int) {
            Task {
                switch await repository.checkInReactions.delete(id: reactionId) {
                case .success():
                    await MainActor.run {
                        self.checkInReactions.removeAll(where: { $0.id == reactionId })
                    }

                case let .failure(error):
                    print(error)
                }
            }
        }
    }
}
