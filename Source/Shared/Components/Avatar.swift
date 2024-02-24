import Components
import EnvironmentModels
import Models
import SwiftUI

@MainActor
struct Avatar: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel

    let profile: Profile

    public init(profile: Profile) {
        self.profile = profile
    }

    var body: some View {
        AvatarView(profile: profile, baseUrl: appEnvironmentModel.infoPlist.supabaseUrl)
    }
}
