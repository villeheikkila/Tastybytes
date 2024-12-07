import Components

import Logging
import Models
import Repositories
import SwiftUI

struct AppInfoScreen: View {
    @Environment(ProfileModel.self) private var profileModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section("about.appInfo.section.profile") {
                CopyableLabel(title: "labels.id", value: profileModel.id.rawValue.uuidString)
                CopyableLabel(title: "profile.deviceId.label", value: profileModel.deviceToken?.rawValue ?? "-")
            }
            .textSelection(.enabled)
        }
        .listStyle(.insetGrouped)
        .navigationTitle("about.appInfo.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CopyableLabel: View {
    @Environment(SnackController.self) private var snackController
    let title: LocalizedStringKey
    let value: String

    var body: some View {
        LabeledContent(title) {
            Text(value)
                .onTapGesture {
                    UIPasteboard.general.string = value
                    snackController
                        .open(.init(mode: .snack(tint: .green, systemName: "doc.on.clipboard", message: "labels.copied")))
                }
        }
    }
}
