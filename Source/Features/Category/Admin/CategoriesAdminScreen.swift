import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct CategoriesAdminScreen: View {
    private let logger = Logger(category: "CategoriesAdminScreen")
    @Environment(Router.self) private var router
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel

    var body: some View {
        List(appEnvironmentModel.categories) { category in
            CategoryAdminRowView(category: category)
        }
        .listStyle(.plain)
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
    let category: Models.Category.JoinedSubcategoriesServingStyles

    var body: some View {
        RouterLink(open: .sheet(.categoryAdmin(id: category.id))) {
            CategoryEntityView(category: category)
        }
    }
}
