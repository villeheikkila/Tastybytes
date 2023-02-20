import SwiftUI

struct ReactionsView: View {
  @EnvironmentObject private var profileManager: ProfileManager
  @StateObject private var hapticManager = HapticManager()
  @StateObject private var viewModel: ViewModel

  init(_ client: Client, checkIn: CheckIn) {
    _viewModel = StateObject(wrappedValue: ViewModel(client, checkIn: checkIn))
  }

  var body: some View {
    HStack {
      ForEach(viewModel.checkInReactions, id: \.id) {
        reaction in AvatarView(avatarUrl: reaction.profile.avatarUrl, size: 16, id: reaction.profile.id)
      }

      HStack {
        Text("\(viewModel.checkInReactions.count)")
          .font(.system(size: 12, weight: .bold, design: .default))
          .foregroundColor(.primary)

        Image(systemName: "hand.thumbsup.fill")
          .frame(height: 16, alignment: .leading)
          .foregroundColor(Color(.systemYellow))
      }
    }
    .if(!viewModel.isLoading, transform: { view in
      view.accessibilityAddTraits(.isButton)
        .onTapGesture {
          hapticManager.trigger(of: .impact(intensity: .low))
          viewModel.toggleReaction(userId: profileManager.getId())
        }
    })
    .disabled(viewModel.isLoading)
  }
}
