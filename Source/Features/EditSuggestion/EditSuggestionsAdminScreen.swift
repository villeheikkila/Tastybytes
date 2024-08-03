import Components

import Models
import SwiftUI

struct EditSuggestionAdminScreen: View {
    @Environment(AdminModel.self) private var adminModel

    var body: some View {
        List(adminModel.editSuggestions) { editSuggestion in
            EditSuggestionRowView(editSuggestion: editSuggestion)
                .swipeActions {
                    AsyncButton("labels.delete", systemImage: "trash") {
                        await adminModel.deleteEditSuggestion(editSuggestion)
                    }
                    .labelStyle(.iconOnly)
                    .tint(.red)
                }
        }
        .listStyle(.plain)
        .animation(.default, value: adminModel.editSuggestions)
        .overlay {
            if adminModel.editSuggestions.isEmpty {
                ContentUnavailableView("editSuggestions.empty.title", systemImage: "tray")
            }
        }
        .navigationTitle("editSuggestions.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await adminModel.loadEditSuggestions()
        }
        .task {
            await adminModel.loadEditSuggestions()
        }
    }
}

struct EditSuggestionRowView: View {
    let editSuggestion: EditSuggestion

    var body: some View {
        Section {
            RouterLink(open: editSuggestion.open) {
                EditSuggestionView(editSuggestion: editSuggestion)
            }
        }
    }
}
