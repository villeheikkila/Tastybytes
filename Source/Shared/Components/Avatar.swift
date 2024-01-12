import Components
import EnvironmentModels
import Models
import SwiftUI

struct Avatar: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel

    let profile: Profile
    let size: Double

    public init(profile: Profile, size: Double = 24) {
        self.profile = profile
        self.size = size
    }

    var body: some View {
        AvatarView(profile: profile, baseUrl: appEnvironmentModel.infoPlist.supabaseUrl, size: size)
    }
}
