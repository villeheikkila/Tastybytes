import EnvironmentModels
import Models
import SwiftUI

struct Avatar: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel

    let profile: Profile

    var body: some View {
        AvatarView(profile: profile, baseUrl: appEnvironmentModel.infoPlist.supabaseUrl)
    }
}
