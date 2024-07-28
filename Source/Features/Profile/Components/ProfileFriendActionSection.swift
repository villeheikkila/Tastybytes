import Components

import Models
import SwiftUI

struct ProfileFriendActionSection: View {
    @Environment(ProfileModel.self) private var profileModel

    let profile: Profile.Saved

    var body: some View {
        HStack {
            Spacer()
            Group {
                if profileModel.hasNoFriendStatus(friend: profile) {
                    AsyncButton(
                        "friend.friendRequest.send.label",
                        action: { await profileModel.sendFriendRequest(receiver: profile.id) }
                    )
                } else if let friend = profileModel.isPendingCurrentUserApproval(profile) {
                    AsyncButton(
                        "friend.friendRequest.accept.label",
                        action: {
                            await profileModel.updateFriendRequest(friend: friend, newStatus: .accepted)
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
