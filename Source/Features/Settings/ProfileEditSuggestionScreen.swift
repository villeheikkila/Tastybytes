import Components
import Models
import OSLog
import Repositories
import SwiftUI
import EnvironmentModels

struct ProfileEditSuggestionScreen: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    
    var editSuggestions: [EditSuggestion] {
        profileEnvironmentModel.contributions?.editSuggestions ?? []
    }

    var body: some View {
        List(editSuggestions) { editSuggestion in
            EditSuggestionEntityView(editSuggestion: editSuggestion)
                .swipeActions {
                    AsyncButton("labels.delete", systemImage: "trash") {
                        await profileEnvironmentModel.deleteEditSuggestion(editSuggestion)
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
