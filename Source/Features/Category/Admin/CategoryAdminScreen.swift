import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct CategoryAdminScreen: View {
    private let logger = Logger(category: "CategoryAdminScreen")
    @Environment(Router.self) private var router
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel

    var body: some View {
        List(appEnvironmentModel.categories) { category in
            CategoryAdminRowView(category: category)
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await appEnvironmentModel.initialize(reset: true)
        }
        .navigationBarTitle("category.title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            RouterLink(
                "category.add.label",
                systemImage: "plus",
                open: .sheet(.categoryCreation(onSubmit: { _ in
                    router.open(.toast(.success("category.add.success.toast")))
                }))
            )
            .labelStyle(.iconOnly)
            .bold()
        }
    }
}

struct CategoryAdminRowView: View {
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel

    let category: Models.Category.JoinedSubcategoriesServingStyles

    var body: some View {
        RouterLink(open: .sheet(.categoryAdmin(id: category.id))) {
            HStack {
                Text(category.name)
                Spacer()
            }
        }
    }
}
