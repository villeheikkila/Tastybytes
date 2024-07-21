import Components
import EnvironmentModels
import Models
import SwiftUI

struct EditSuggestionAdminScreen: View {
    @Environment(AdminEnvironmentModel.self) private var adminEnvironmentModel

    var body: some View {
        List(adminEnvironmentModel.editSuggestions) { editSuggestion in
            EditSuggestionRowView(editSuggestion: editSuggestion)
                .swipeActions {
                    AsyncButton("labels.delete", systemImage: "trash") {
                        await adminEnvironmentModel.deleteEditSuggestion(editSuggestion)
                    }
                    .labelStyle(.iconOnly)
                    .tint(.red)
                }
        }
        .listStyle(.plain)
        .animation(.default, value: adminEnvironmentModel.editSuggestions)
        .overlay {
            if adminEnvironmentModel.editSuggestions.isEmpty {
                ContentUnavailableView("editSuggestions.empty.title", systemImage: "tray")
            }
        }
        .navigationTitle("editSuggestions.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await adminEnvironmentModel.loadEditSuggestions()
        }
        .task {
            await adminEnvironmentModel.loadEditSuggestions()
        }
    }
}

struct EditSuggestionRowView: View {
    let editSuggestion: EditSuggestion

    var body: some View {
        Section {
            switch editSuggestion {
            case let .product(editSuggestion):
                RouterLink(open: .sheet(.productAdmin(id: editSuggestion.product.id, onDelete: {}, onUpdate: {}))) {
                    ProductEditSuggestionEntityView(editSuggestion: editSuggestion)
                }
            case let .brand(editSuggestion):
                RouterLink(open: .sheet(.brandAdmin(id: editSuggestion.brand.id, onUpdate: { _ in }, onDelete: { _ in }))) {
                    BrandEditSuggestionEntityView(editSuggestion: editSuggestion)
                }
            case let .subBrand(editSuggestion):
                RouterLink(open: .sheet(.brandAdmin(id: editSuggestion.subBrand.brand.id, onUpdate: { _ in }, onDelete: { _ in }))) {
                    SubBrandEditSuggestionEntityView(editSuggestion: editSuggestion)
                }
            case let .company(editSuggestion):
                RouterLink(open: .sheet(.companyAdmin(id: editSuggestion.company.id, onUpdate: {}, onDelete: {}))) {
                    CompanyEditSuggestionEntityView(editSuggestion: editSuggestion)
                }
            }
        }
    }
}
