import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct AdminEventScreen: View {
    let logger = Logger(category: "AdminEventScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(AdminEnvironmentModel.self) private var adminEnvironmentModel

    var body: some View {
        List(adminEnvironmentModel.events) { event in
            AdminEventRowView(event: event)
        }
        .refreshable {
            await adminEnvironmentModel.loadAdminEventFeed()
        }
        .animation(.default, value: adminEnvironmentModel.events)
        .navigationTitle("admin.events.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await adminEnvironmentModel.loadAdminEventFeed()
        }
    }
}

struct AdminEventRowView: View {
    @Environment(AdminEnvironmentModel.self) private var adminEnvironmentModel
    let event: AdminEvent

    var body: some View {
        Section {
            RouterLink(open: event.open) {
                AdminEventContentEntityView(content: event.content)
            }
            .buttonStyle(.plain)
        } header: {
            Text(event.sectionTitle)
        } footer: {
            Text(event.createdAt.formatted())
        }
        .contentShape(.rect)
        .swipeActions {
            AsyncButton("labels.ok", systemImage: "checkmark") {
                await adminEnvironmentModel.markAsReviewed(event)
            }
            .tint(.green)
        }
    }
}
