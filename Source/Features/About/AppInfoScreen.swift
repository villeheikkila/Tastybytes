import Components

import Logging
import Models
import Repositories
import SwiftUI

struct AppInfoScreen: View {
    @Environment(ProfileModel.self) private var profileModel
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section {
                LabeledContent("labels.id", value: profileModel.id.rawValue.uuidString)
                LabeledContent("profile.deviceId.label", value: profileModel.deviceToken ?? "-")
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("about.appInfo.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
