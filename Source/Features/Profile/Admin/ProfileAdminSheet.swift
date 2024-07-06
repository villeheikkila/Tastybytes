import EnvironmentModels
import Models
import Repositories
import SwiftUI

struct ProfileAdminSheet: View {
    let profile: Profile

    var body: some View {
        Form {
            content
        }
        .navigationTitle("profile.admin.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ViewBuilder private var content: some View {
        Section("profile.admin.section.profile") {
            RouterLink(open: .screen(.profile(profile))) {
                ProfileEntityView(profile: profile)
            }
        }
        Section("admin.section.details") {
            LabeledIdView(id: profile.id.uuidString)
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

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }
}
