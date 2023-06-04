import SwiftUI

struct ReactionsView: View {
  private let logger = getLogger(category: "ReactionsView")
  @EnvironmentObject private var repository: Repository
  @EnvironmentObject private var profileManager: ProfileManager
  @EnvironmentObject private var feedbackManager: FeedbackManager
  @State private var checkInReactions = [CheckInReaction]()
  @State private var isLoading = false

  let checkIn: CheckIn

  private let size: Double = 24

  init(checkIn: CheckIn) {
    self.checkIn = checkIn
    _checkInReactions = State(initialValue: checkIn.checkInReactions)
  }

  var body: some View {
    HStack(alignment: .center) {
      Spacer()
      ForEach(checkInReactions) { reaction in
        AvatarView(avatarUrl: reaction.profile.avatarUrl, size: size, id: reaction.profile.id)
      }
      Label(
        "React to check-in",
        systemImage: "hand.thumbsup"
      )
      .labelStyle(.iconOnly)
      .symbolVariant(hasReacted(profileManager.profile) ? .fill : .none)
      .imageScale(.large)
      .foregroundColor(Color(.systemYellow))
    }
    .frame(maxWidth: 80, minHeight: size + 4)
    .contentShape(Rectangle())
    .if(!isLoading, transform: { view in
      view
        .accessibilityAddTraits(.isButton)
        .onTapGesture {
          Task {
            await toggleReaction()
          }
        }
    })
    .disabled(isLoading)
  }

  func hasReacted(_ profile: Profile) -> Bool {
    checkInReactions.contains(where: { $0.profile.id == profile.id })
  }

  func toggleReaction() async {
    isLoading = true
    if let reaction = checkInReactions.first(where: { $0.profile.id == profileManager.id }) {
      switch await repository.checkInReactions.delete(id: reaction.id) {
      case .success:
        withAnimation {
          checkInReactions.remove(object: reaction)
        }
        feedbackManager.trigger(.impact(intensity: .low))
      case let .failure(error):
        guard !error.localizedDescription.contains("cancelled") else { return }
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
        guard !error.localizedDescription.contains("cancelled") else { return }
        feedbackManager.toggle(.error(.unexpected))
        logger
          .error(
            "adding check-in reaction for check-in \(checkIn.id) by \(profileManager.id) failed:\(error.localizedDescription)"
          )
      }
    }
    isLoading = false
  }
}
