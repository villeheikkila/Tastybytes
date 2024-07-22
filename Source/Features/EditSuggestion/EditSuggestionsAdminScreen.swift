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
            RouterLink(open: editSuggestion.open) {
                EditSuggestionEntityView(editSuggestion: editSuggestion)
            }
        }
    }
}
