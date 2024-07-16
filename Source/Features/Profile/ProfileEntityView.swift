import Models
import SwiftUI

struct ProfileEntityView: View {
    let profile: Profile

    var body: some View {
        HStack(alignment: .center) {
            Avatar(profile: profile)
                .avatarSize(.extraLarge)
            VStack {
                HStack {
                    Text(profile.preferredName)
                        .padding(.leading, 8)
                    Spacer()
                }
            }
        }
        .contentShape(.rect)
    }
}
