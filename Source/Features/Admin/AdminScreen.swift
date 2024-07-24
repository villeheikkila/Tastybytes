import EnvironmentModels
import SwiftUI

struct AdminScreen: View {
    @Environment(AdminEnvironmentModel.self) private var adminEnvironmentModel

    var body: some View {
        List {
            Section("admin.section.activity.title") {
                RouterLink(
                    "admin.events.title",
                    systemImage: "bell.badge",
                    badge: adminEnvironmentModel.events.count,
                    open: .screen(.adminEvent)
                )
                RouterLink(
                    "admin.verification.title",
                    systemImage: "checkmark.seal",
                    badge: adminEnvironmentModel.unverified.count,
                    open: .screen(.verification)
                )
                RouterLink(
                    "admin.editsSuggestions.title",
                    systemImage: "slider.horizontal.2.square.on.square",
                    badge: adminEnvironmentModel.editSuggestions.count,
                    open: .screen(.editSuggestionsAdmin)
                )
                RouterLink(
                    "report.admin.navigationTitle",
                    systemImage: "exclamationmark.bubble",
                    badge: adminEnvironmentModel.reports.count,
                    open: .screen(.reportsAdmin)
                )
            }
            .foregroundColor(.primary)

            Section("admin.section.management.title") {
                RouterLink("admin.category.title", systemImage: "rectangle.stack", open: .screen(.categoriesAdmin))
                RouterLink("flavor.navigationTitle", systemImage: "face.smiling", open: .screen(.flavorAdmin))
                RouterLink("companiesAdmin.navigationTitle", systemImage: "briefcase", open: .screen(.companiesAdmin))
                RouterLink("brandsAdmin.navigationTitle", systemImage: "tag", open: .screen(.brandsAdmin))
                RouterLink("productsAdmin.navigationTitle", systemImage: "cart", open: .screen(.productsAdmin))
                RouterLink("admin.locations.title", systemImage: "mappin.square", open: .screen(.locationAdmin))
                RouterLink("admin.profiles.title", systemImage: "person", open: .screen(.profilesAdmin))
            }
            .foregroundColor(.primary)
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await adminEnvironmentModel.initialize()
        }
        .navigationBarTitle("admin.navigationTitle")
    }
}
