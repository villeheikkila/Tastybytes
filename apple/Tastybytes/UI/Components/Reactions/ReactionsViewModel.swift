import SwiftUI

extension ReactionsView {
  @MainActor class ViewModel: ObservableObject {
    private let logger = getLogger(category: "ReactionsView")
    let client: Client
    @Published var checkInReactions = [CheckInReaction]()
    @Published var isLoading = false

    let checkIn: CheckIn

    func hasReacted(_ profile: Profile) -> Bool {
      checkInReactions.contains(where: { $0.profile.id == profile.id })
    }

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
