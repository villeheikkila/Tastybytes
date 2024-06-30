import Components
import EnvironmentModels
import Models
import SwiftUI

struct ProfileFriendActionSection: View {
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel

    let profile: Profile

    var body: some View {
        HStack {
            Spacer()
            Group {
                if friendEnvironmentModel.hasNoFriendStatus(friend: profile) {
                    ProgressButton(
                        "friend.friendRequest.send.label",
                        action: { await friendEnvironmentModel.sendFriendRequest(receiver: profile.id) }
                    )
                } else if let friend = friendEnvironmentModel.isPendingCurrentUserApproval(profile) {
                    ProgressButton(
                        "friend.friendRequest.accept.label",
                        action: {
                            await friendEnvironmentModel.updateFriendRequest(friend: friend, newStatus: .accepted)
                        }
                    )
                }
            }
            .font(.headline)
            .buttonStyle(.scalingButton)
            Spacer()
        }
    }
}
