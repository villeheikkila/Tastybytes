import Components
import Models
import Logging
import Repositories
import SwiftUI

struct SubBrandEditSuggestionsScreen: View {
    let logger = Logger(label: "SubBrandEditSuggestionsScreen")
    @Environment(Router.self) private var router
    @Environment(Repository.self) private var repository
    @Binding var subBrand: SubBrand.Detailed
    let initialEditSuggestion: SubBrand.EditSuggestion.Id?

    var body: some View {
        List(subBrand.editSuggestions) { editSuggestion in
            SubBrandEditSuggestionRowView(editSuggestion: editSuggestion, onDelete: onDelete)
        }
        .overlay {
            if subBrand.editSuggestions.isEmpty {
                ContentUnavailableView("admin.noEditSuggestions.title", systemImage: "tray")
            }
        }
        .navigationTitle("subBrand.editSuggestion.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .scrollToPosition(id: initialEditSuggestion)
    }

    private func onDelete(_ editSuggestion: SubBrand.EditSuggestion) async {
        do {
            try await repository.subBrand.deleteEditSuggestion(editSuggestion: editSuggestion)
            subBrand = subBrand.copyWith(editSuggestions: subBrand.editSuggestions.removing(editSuggestion))
        } catch {
            guard !error.isCancelled else { return }
            router.open(.alert(.init()))
            logger.error("Failed to delete sub-brand edit suggestion '\(editSuggestion.id)'. Error: \(error) (\(#file):\(#line))")
        }
    }
}

struct SubBrandEditSuggestionRowView: View {
    @State private var showDeleteConfirmationDialog = false
    let editSuggestion: SubBrand.EditSuggestion
    let onDelete: (_ editSuggestion: SubBrand.EditSuggestion) async -> Void

    var body: some View {
        SubBrandEditSuggestionView(editSuggestion: editSuggestion)
            .swipeActions {
                Button("labels.delete", systemImage: "trash") {
                    showDeleteConfirmationDialog = true
                }
            }
            .confirmationDialog(
                "company.admin.editSuggestion.delete.description",
                isPresented: $showDeleteConfirmationDialog,
                titleVisibility: .visible,
                presenting: editSuggestion
            ) { presenting in
                AsyncButton(
                    "company.admin.editSuggestion.delete.label \(presenting.name ?? "-")",
                    action: {
                        await onDelete(presenting)
                    }
                )
                .tint(.green)
            }
    }
}
