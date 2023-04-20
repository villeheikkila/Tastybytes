import SwiftUI

struct ReactionsView: View {
  private let logger = getLogger(category: "ReactionsView")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @State private var checkInReactions = [CheckInReaction]()
  @State private var isLoading = false

  let checkIn: CheckIn

  init(checkIn: CheckIn) {
    self.checkIn = checkIn
    _checkInReactions = State(initialValue: checkIn.checkInReactions)
  }

  var body: some View {
    HStack {
      Spacer()
      ForEach(checkInReactions) { reaction in
        AvatarView(avatarUrl: reaction.profile.avatarUrl, size: 16, id: reaction.profile.id)
      }
      Label(
        "React to check-in",
        systemImage: hasReacted(profileManager.profile) ? "hand.thumbsup.fill" : "hand.thumbsup"
      )
      .labelStyle(.iconOnly)
      .imageScale(.medium)
      .foregroundColor(Color(.systemYellow))
    }
    .frame(maxWidth: 80)
    .contentShape(Rectangle())
    .if(!isLoading, transform: { view in
      view.accessibilityAddTraits(.isButton)
        .onTapGesture {
          Task {
            await toggleReaction(userId: profileManager.id)
          }
        }
    })
    .disabled(isLoading)
  }

  func hasReacted(_ profile: Profile) -> Bool {
    checkInReactions.contains(where: { $0.profile.id == profile.id })
  }

  func toggleReaction(userId: UUID) async {
    isLoading = true
    if let reaction = checkInReactions.first(where: { $0.profile.id == userId }) {
      switch await repository.checkInReactions.delete(id: reaction.id) {
      case .success:
        withAnimation {
          checkInReactions.remove(object: reaction)
        }
        feedbackManager.trigger(.impact(intensity: .low))
      case let .failure(error):
        feedbackManager.toggle(.error(.unexpected))
        logger.error("removing check-in reaction \(reaction.id) failed: \(error.localizedDescription)")
      }
    } else {
      switch await repository.checkInReactions
        .insert(newCheckInReaction: CheckInReaction.NewRequest(checkInId: checkIn.id))
      {
      case let .success(checkInReaction):
        withAnimation {
          checkInReactions.append(checkInReaction)
        }
        feedbackManager.trigger(.notification(.success))
      case let .failure(error):
        feedbackManager.toggle(.error(.unexpected))
        logger.error("adding check-in reaction for check-in \(checkIn.id) by \(userId) failed:\(error.localizedDescription)")
      }
    }
    isLoading = false
  }
}
