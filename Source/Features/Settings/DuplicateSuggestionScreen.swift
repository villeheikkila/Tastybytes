import Components
import Models
import OSLog
import Repositories
import SwiftUI
import EnvironmentModels

struct ProfileDuplicateSuggestionScreen: View {
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    
    var duplicateSuggestions: [DuplicateSuggestion] {
        profileEnvironmentModel.contributions?.duplicateSuggestions ?? []
    }

    var body: some View {
        List(duplicateSuggestions) { duplicateSuggestion in
            DuplicateSuggesEntityView(duplicateSuggestion: duplicateSuggestion)
                .swipeActions {
                    AsyncButton("labels.delete", systemImage: "trash") {
                        await profileEnvironmentModel.deleteDuplicateSuggestion(duplicateSuggestion)
                    }
                    .labelStyle(.iconOnly)
                    .tint(.red)
                }
        }
        .listStyle(.plain)
        .animation(.default, value: duplicateSuggestions)
        .overlay {
            if duplicateSuggestions.isEmpty {
                ContentUnavailableView("duplicateSuggestions.empty.title", systemImage: "tray")
            }
        }
        .navigationTitle("duplicateSuggestions.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DuplicateSuggesEntityView: View {
    let duplicateSuggestion: DuplicateSuggestion

    var body: some View {
        switch duplicateSuggestion {
        case let .product(duplicateSuggestion):
            DuplicateProductSuggestionEntityView(duplicateProductSuggestion: duplicateSuggestion)
        }
    }
}
