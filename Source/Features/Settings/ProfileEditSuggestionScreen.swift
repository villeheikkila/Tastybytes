import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct ProfileEditSuggestionScreen: View {
    let contributionsModel: ContributionsModel

    var editSuggestions: [EditSuggestion] {
        contributionsModel.contributions?.editSuggestions ?? []
    }

    var body: some View {
        List(editSuggestions) { editSuggestion in
            EditSuggestionEntityView(editSuggestion: editSuggestion)
                .swipeActions {
                    AsyncButton("labels.delete", systemImage: "trash") {
                        await contributionsModel.deleteEditSuggestion(editSuggestion)
                    }
                    .labelStyle(.iconOnly)
                    .tint(.red)
                }
        }
        .listStyle(.plain)
        .animation(.default, value: editSuggestions)
        .overlay {
            if editSuggestions.isEmpty {
                ContentUnavailableView("editSuggestions.empty.title", systemImage: "tray")
            }
        }
        .navigationTitle("editSuggestions.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EditSuggestionEntityView: View {
    let editSuggestion: EditSuggestion

    var body: some View {
        switch editSuggestion {
        case let .brand(editSuggestion):
            BrandEditSuggestionEntityView(editSuggestion: editSuggestion)
        case let .product(editSuggestion):
            ProductEditSuggestionEntityView(editSuggestion: editSuggestion)
        case let .company(editSuggestion):
            CompanyEditSuggestionEntityView(editSuggestion: editSuggestion)
        case let .subBrand(editSuggestion):
            SubBrandEditSuggestionEntityView(editSuggestion: editSuggestion)
        }
    }
}
