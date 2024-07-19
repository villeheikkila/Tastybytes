import Components
import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

struct ProfileDuplicateSuggestionScreen: View {
    let contributionsModel: ContributionsModel

    var duplicateSuggestions: [DuplicateSuggestion] {
        contributionsModel.contributions?.duplicateSuggestions ?? []
    }

    var body: some View {
        List(duplicateSuggestions) { duplicateSuggestion in
            DuplicateSuggesEntityView(duplicateSuggestion: duplicateSuggestion)
                .swipeActions {
                    AsyncButton("labels.delete", systemImage: "trash") {
                        await contributionsModel.deleteDuplicateSuggestion(duplicateSuggestion)
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
