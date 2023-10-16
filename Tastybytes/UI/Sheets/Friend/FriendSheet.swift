import Components
import EnvironmentModels
import Models
import SwiftUI

struct FriendSheet: View {
    @Binding private var taggedFriends: [Profile]
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchTerm: String = ""
    @State private var selectedFriendIds: Set<UUID> = Set()

    init(taggedFriends: Binding<[Profile]>) {
        _taggedFriends = taggedFriends
        _selectedFriendIds = State(initialValue: Set(taggedFriends.map(\.id)))
    }

    private var shownProfiles: [Profile] {
        friendEnvironmentModel.acceptedFriends
            .filter { searchTerm.isEmpty || $0.preferredName.lowercased().contains(searchTerm.lowercased()) }
    }

    private var sortedShownProfiles: [Profile] {
        shownProfiles.sorted { selectedFriendIds.contains($0.id) && !selectedFriendIds.contains($1.id) }
    }

    private var showContentUnavailableView: Bool {
        !searchTerm.isEmpty && sortedShownProfiles.isEmpty
    }

    private var selectedFriendIdsAsFrieds: [Profile] {
        selectedFriendIds.compactMap { flavor in
            friendEnvironmentModel.acceptedFriends.first(where: { $0.id == flavor })
        }
    }

    var body: some View {
        List(sortedShownProfiles, selection: $selectedFriendIds) { friend in
            HStack {
                AvatarView(avatarUrl: friend.avatarUrl, size: 42, id: friend.id)
                Text(friend.preferredName).padding(.leading, 8)
                Spacer()
            }
        }
        .environment(\.editMode, .constant(.active))
        .searchable(text: $searchTerm)
        .overlay {
            ContentUnavailableView.search(text: searchTerm)
                .opacity(showContentUnavailableView ? 1 : 0)
        }
        .navigationTitle("Friends")
        .toolbar {
            toolbarContent
        }
        .onChange(of: selectedFriendIds) {
            taggedFriends = selectedFriendIdsAsFrieds
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button("Done", action: { dismiss() })
                .bold()
        }
    }
}
