import SwiftUI

struct ReactionsView: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @StateObject private var viewModel: ViewModel

  init(checkIn: CheckIn) {
    _viewModel = StateObject(wrappedValue: ViewModel(checkIn: checkIn))
  }

  var body: some View {
    HStack {
      ForEach(viewModel.checkInReactions, id: \.id) {
        reaction in AvatarView(avatarUrl: reaction.profile.getAvatarURL(), size: 24, id: reaction.profile.id)
      }

      Button {
        viewModel.toggleReaction(userId: profileManager.getId())
      } label: {
        Text("\(viewModel.checkInReactions.count)")
          .font(.system(size: 14, weight: .bold, design: .default))
          .foregroundColor(.primary)

        Image(systemName: "hand.thumbsup.fill")
          .frame(height: 24, alignment: .leading)
          .foregroundColor(Color(.systemYellow))
      }
      .disabled(viewModel.isLoading)
    }
  }
}

extension ReactionsView {
  @MainActor class ViewModel: ObservableObject {
    @Published var checkInReactions = [CheckInReaction]()
    @Published var isLoading = false

    let checkIn: CheckIn

    init(checkIn: CheckIn) {
      self.checkIn = checkIn
      checkInReactions = checkIn.checkInReactions
    }

    func toggleReaction(userId: UUID) {
      isLoading = true
      Task {
        if let reaction = checkInReactions.first(where: { $0.profile.id == userId }) {
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
        } else {
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
        isLoading = false
      }
    }
  }
}
