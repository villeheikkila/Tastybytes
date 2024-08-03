import Components

import Models
import OSLog
import Repositories
import SwiftUI

struct EditSuggestionsProfileScreen: View {
    let contributionsModel: ContributionsModel

    var editSuggestions: [EditSuggestion] {
        contributionsModel.contributions?.editSuggestions ?? []
    }

    var body: some View {
        List(editSuggestions) { editSuggestion in
            EditSuggestionView(editSuggestion: editSuggestion)
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
