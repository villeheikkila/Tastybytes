import EnvironmentModels
import Models
import Repositories
import SwiftUI

struct ProfileAdminSheet: View {
    let profile: Profile

    var body: some View {
        Form {
            Section("profile.admin.section.profile") {
                RouterLink(open: .screen(.profile(profile))) {
                    ProfileEntityView(profile: profile)
                }
            }

            Section("admin.section.details") {
                LabeledContent("labels.id", value: profile.id.uuidString)
                    .textSelection(.enabled)
                    .multilineTextAlignment(.trailing)
                LabeledContent("profile.admin.joinedAt.label", value: profile.joinedAt.formatted(.dateTime
                        .year()
                        .month(.wide)
                        .day()))
            }

            Section {
                RouterLink("admin.section.reports.title", systemImage: "exclamationmark.bubble", open: .screen(.reports(.profile(profile.id))))
                RouterLink("contributions.title", systemImage: "plus", open: .screen(.contributions(profile)))
            }
        }
        .navigationTitle("profile.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarDismissAction()
        }
    }
}
