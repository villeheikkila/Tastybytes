import EnvironmentModels
import SwiftUI

struct AdminScreen: View {
    @Environment(AdminEnvironmentModel.self) private var adminEnvironmentModel

    var body: some View {
        List {
            Section {
                RouterLink("admin.events.title", systemImage: "bell.badge", open: .screen(.adminEvent))
            }

            Section("admin.section.data.title") {
                RouterLink("admin.category.title", systemImage: "rectangle.stack", open: .screen(.categoryAdmin))
                RouterLink("flavor.navigationTitle", systemImage: "face.smiling", open: .screen(.flavorAdmin))
            }
            Section("admin.section.reports.title") {
                RouterLink("admin.duplicates.title", systemImage: "plus.square.on.square", open: .screen(.duplicateProducts(filter: .all)))
                RouterLink("report.admin.navigationTitle", systemImage: "exclamationmark.bubble", open: .screen(.reports(nil)))
            }
            Section("admin.section.management.title") {
                RouterLink("admin.verification.title", systemImage: "checkmark.seal", open: .screen(.verification))
                RouterLink("admin.locations.title", systemImage: "mappin.square", open: .screen(.locationAdmin))
                RouterLink("admin.profiles.title", systemImage: "person", open: .screen(.profilesAdmin))
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitle("admin.navigationTitle")
    }
}
