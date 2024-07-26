
import Models
import SwiftUI

struct Avatar: View {
    @Environment(AppModel.self) private var appModel

    let profile: ProfileProtocol

    var body: some View {
        AvatarView(profile: profile, baseUrl: appModel.infoPlist.supabaseUrl)
    }
}
