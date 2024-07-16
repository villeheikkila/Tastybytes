import Components
import EnvironmentModels
import Extensions
import Models
import SwiftUI

struct FriendPickerSheet: View {
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchTerm: String = ""
    @Binding var taggedFriends: [Profile]

    private var shownProfiles: [Profile] {
        friendEnvironmentModel.acceptedFriends.filteredBySearchTerm(by: \.preferredName, searchTerm: searchTerm)
    }

    private var sortedShownProfiles: [Profile] {
        shownProfiles.sorted { taggedFriends.contains($0) && !taggedFriends.contains($1) }
    }

    private var showContentUnavailableView: Bool {
        !searchTerm.isEmpty && sortedShownProfiles.isEmpty
    }

    var body: some View {
        List(sortedShownProfiles, selection: $taggedFriends.map(getter: { friends in
            Set(friends.map(\.id))
        }, setter: { ids in
            ids.compactMap { id in friendEnvironmentModel.acceptedFriends.first(where: { $0.id == id }) }
        })) { profile in
            ProfileEntityView(profile: profile)
                .listRowBackground(Color.clear)
        }
        .environment(\.editMode, .constant(.active))
        .scrollContentBackground(.hidden)
        .searchable(text: $searchTerm)
        .overlay {
            if friendEnvironmentModel.acceptedFriends.isEmpty {
                ContentUnavailableView("friends.empty.title", systemImage: "tray")
            } else if showContentUnavailableView {
                ContentUnavailableView.search(text: searchTerm)
            }
        }
        .navigationTitle("friends.navigationTitle")
        .toolbar {
            toolbarContent
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }
}
