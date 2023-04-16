import SwiftUI

struct ReactionsView: View {
  private let logger = getLogger(category: "ReactionsView")
  @EnvironmentObject private var client: AppClient
  @EnvironmentObject private var profileManager: ProfileManager
  @StateObject private var hapticManager = HapticManager()
  @State private var checkInReactions = [CheckInReaction]()
  @State private var isLoading = false

  let checkIn: CheckIn

  init(checkIn: CheckIn) {
    self.checkIn = checkIn
    checkInReactions = checkIn.checkInReactions
  }

  var body: some View {
    HStack {
      Spacer()
      ForEach(checkInReactions) { reaction in
        AvatarView(avatarUrl: reaction.profile.avatarUrl, size: 16, id: reaction.profile.id)
      }
      Label(
        "React to check-in",
        systemImage: hasReacted(profileManager.getProfile()) ? "hand.thumbsup.fill" : "hand.thumbsup"
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
            await toggleReaction(userId: profileManager.getId())
            hapticManager.trigger(.impact(intensity: .low))
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
    Task {
      if let reaction = checkInReactions.first(where: { $0.profile.id == userId }) {
        switch await client.checkInReactions.delete(id: reaction.id) {
        case .success:
          withAnimation {
            checkInReactions.remove(object: reaction)
          }
        case let .failure(error):
          logger.error("removing check-in reaction \(reaction.id) failed: \(error.localizedDescription)")
        }
      } else {
        switch await client.checkInReactions
          .insert(newCheckInReaction: CheckInReaction.NewRequest(checkInId: checkIn.id))
        {
        case let .success(checkInReaction):
          withAnimation {
            checkInReactions.append(checkInReaction)
          }
        case let .failure(error):
          logger.error("adding check-in reaction for check-in \(checkIn.id) by \(userId) failed:\(error.localizedDescription)")
        }
      }
      isLoading = false
    }
  }
}
