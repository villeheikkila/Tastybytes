import Components

import Models
import OSLog
import Repositories
import SwiftUI

struct AdminEventScreen: View {
    let logger = Logger(category: "AdminEventScreen")
    @Environment(Repository.self) private var repository
    @Environment(Router.self) private var router
    @Environment(AdminModel.self) private var adminModel

    var body: some View {
        List(adminModel.events) { event in
            AdminEventRowView(event: event)
        }
        .refreshable {
            await adminModel.loadAdminEventFeed()
        }
        .animation(.default, value: adminModel.events)
        .navigationTitle("admin.events.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await adminModel.loadAdminEventFeed()
        }
    }
}

struct AdminEventRowView: View {
    @Environment(AdminModel.self) private var adminModel
    let event: AdminEvent.Joined

    var body: some View {
        Section {
            RouterLink(open: event.open) {
                AdminEventContentView(content: event.content)
            }
            .foregroundColor(.primary)
        } header: {
            Text(event.sectionTitle)
        } footer: {
            Text(event.createdAt.formatted())
        }
        .contentShape(.rect)
        .swipeActions {
            AsyncButton("labels.ok", systemImage: "checkmark") {
                await adminModel.markAsReviewed(event)
            }
            .tint(.green)
        }
    }
}
