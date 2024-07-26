import Components

import Models
import SwiftUI

struct ProfileFriendActionSection: View {
    @Environment(FriendModel.self) private var friendModel

    let profile: Profile.Saved

    var body: some View {
        HStack {
            Spacer()
            Group {
                if friendModel.hasNoFriendStatus(friend: profile) {
                    AsyncButton(
                        "friend.friendRequest.send.label",
                        action: { await friendModel.sendFriendRequest(receiver: profile.id) }
                    )
                } else if let friend = friendModel.isPendingCurrentUserApproval(profile) {
                    AsyncButton(
                        "friend.friendRequest.accept.label",
                        action: {
                            await friendModel.updateFriendRequest(friend: friend, newStatus: .accepted)
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
