import SwiftUI

struct ReactionsView: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @StateObject private var viewModel = ViewModel()

  let checkIn: CheckIn

  var body: some View {
    HStack {
      ForEach(viewModel.checkInReactions, id: \.id) {
        reaction in AvatarView(avatarUrl: reaction.profile.getAvatarURL(), size: 24, id: reaction.profile.id)
      }

      Button {
        if let existingReaction = viewModel.checkInReactions.first(where: { $0.profile.id == profileManager.getId() }) {
          viewModel.removeReaction(existingReaction)
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
        switch await repository.checkInReactions
          .insert(newCheckInReaction: CheckInReaction.NewRequest(checkInId: checkIn.id))
        {
        case let .success(checkInReaction):
          await MainActor.run {
            withAnimation {
              self.checkInReactions.append(checkInReaction)
            }
          }
        case let .failure(error):
          print(error)
        }
      }
    }

    func removeReaction(_ reaction: CheckInReaction) {
      Task {
        switch await repository.checkInReactions.delete(id: reaction.id) {
        case .success:
          await MainActor.run {
            withAnimation {
              self.checkInReactions.remove(object: reaction)
            }
          }
        case let .failure(error):
          print(error)
        }
      }
    }
  }
}
