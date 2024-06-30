import Components
import EnvironmentModels
import Models
import SwiftUI

struct FriendSheet: View {
    @Binding private var taggedFriends: [Profile]
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(AppEnvironmentModel.self) private var appEnvironmentModel
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
            FriendSheetRow(friend: friend)
        }
        .environment(\.editMode, .constant(.active))
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
        .onChange(of: selectedFriendIds) {
            taggedFriends = selectedFriendIdsAsFrieds
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDoneActionView()
    }
}

struct FriendSheetRow: View {
    let friend: Profile

    var body: some View {
        HStack {
            Avatar(profile: friend)
                .avatarSize(.extraLarge)
            Text(friend.preferredName).padding(.leading, 8)
            Spacer()
        }
        .listRowBackground(Color.clear)
    }
}
