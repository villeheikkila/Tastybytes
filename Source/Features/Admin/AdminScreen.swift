
import SwiftUI

struct AdminTab: View {
    @Environment(AdminModel.self) private var adminModel

    var body: some View {
        List {
            Section("admin.section.activity.title") {
                RouterLink(
                    "admin.events.title",
                    systemImage: "bell.badge",
                    badge: adminModel.events.count,
                    open: .screen(.adminEvent)
                )
                RouterLink(
                    "admin.verification.title",
                    systemImage: "checkmark.seal",
                    badge: adminModel.unverified.count,
                    open: .screen(.verification)
                )
                RouterLink(
                    "admin.editsSuggestions.title",
                    systemImage: "slider.horizontal.2.square.on.square",
                    badge: adminModel.editSuggestions.count,
                    open: .screen(.editSuggestionsAdmin)
                )
                RouterLink(
                    "report.admin.navigationTitle",
                    systemImage: "exclamationmark.bubble",
                    badge: adminModel.reports.count,
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
            Section("admin.testings.title") {
                RouterLink("experiments.title", systemImage: "testtube.2", open: .screen(.experiments))
            }
            .foregroundColor(.primary)
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await adminModel.initialize()
        }
        .navigationBarTitle("admin.navigationTitle")
        .initialTask {
            await adminModel.initialize()
        }
    }
}
