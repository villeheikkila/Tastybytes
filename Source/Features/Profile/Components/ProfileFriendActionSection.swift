import Components
import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct ProfileFriendActionSection: View {
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel

    let profile: Profile

    var body: some View {
        HStack {
            Spacer()
            Group {
                if friendEnvironmentModel.hasNoFriendStatus(friend: profile) {
                    ProgressButton(
                        "Send Friend Request",
                        action: { await friendEnvironmentModel.sendFriendRequest(receiver: profile.id) }
                    )
                } else if let friend = friendEnvironmentModel.isPendingUserApproval(profile) {
                    ProgressButton(
                        "friends.accept-request.label",
                        action: {
                            await friendEnvironmentModel.updateFriendRequest(friend: friend, newStatus: .accepted)
                        }
                    )
                }
            }
            .font(.headline)
            .buttonStyle(ScalingButton())
            Spacer()
        }
    }
}