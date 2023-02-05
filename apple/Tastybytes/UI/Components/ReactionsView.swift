import SwiftUI

struct ReactionsView: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @StateObject private var viewModel: ViewModel

  init(_ client: Client, checkIn: CheckIn) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, checkIn: checkIn))
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
          .font(.system(size: 12, weight: .bold, design: .default))
          .foregroundColor(.primary)

        Image(systemName: "hand.thumbsup.fill")
          .frame(height: 16, alignment: .leading)
          .foregroundColor(Color(.systemYellow))
      }
      .disabled(viewModel.isLoading)
    }
  }
}

extension ReactionsView {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ReactionsView")
    let client: Client
    @Published var checkInReactions = [CheckInReaction]()
    @Published var isLoading = false

    let checkIn: CheckIn

    init(_ client: Client, checkIn: CheckIn) {
      self.client = client
      self.checkIn = checkIn
      checkInReactions = checkIn.checkInReactions
    }

    func toggleReaction(userId: UUID) {
      isLoading = true
      Task {
        if let reaction = checkInReactions.first(where: { $0.profile.id == userId }) {
          switch await client.checkInReactions.delete(id: reaction.id) {
          case .success:
            withAnimation {
              self.checkInReactions.remove(object: reaction)
            }
          case let .failure(error):
            logger
              .error(
                "removing check-in reaction \(reaction.id) failed: \(error.localizedDescription)"
              )
          }
        } else {
          switch await client.checkInReactions
            .insert(newCheckInReaction: CheckInReaction.NewRequest(checkInId: checkIn.id))
          {
          case let .success(checkInReaction):
            withAnimation {
              self.checkInReactions.append(checkInReaction)
            }
          case let .failure(error):
            logger
              .error(
                """
                adding check-in reaction for check-in \(self.checkIn.id) by \(userId) failed:\
                                \(error.localizedDescription)
                """
              )
          }
        }
        isLoading = false
      }
    }
  }
}
