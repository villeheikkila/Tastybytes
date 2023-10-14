import Components
import EnvironmentModels
import Models
import SwiftUI

struct FriendSheet: View {
    @Binding var taggedFriends: [Profile]
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchTerm: String = ""
    @State private var selectedFriendIds: Set<UUID> = Set()

    var shownFriends: [Profile] {
        friendEnvironmentModel.acceptedFriends
            .filter { searchTerm.isEmpty || $0.preferredName.contains(searchTerm) }
    }

    var shownSortedFriends: [Profile] {
        shownFriends.sorted { selectedFriendIds.contains($0.id) && !selectedFriendIds.contains($1.id) }
    }

    var showContentUnavailableView: Bool {
        !searchTerm.isEmpty && shownFriends.isEmpty
    }

    var selectedFriendIdsAsFrieds: [Profile] {
        selectedFriendIds.compactMap { flavor in
            friendEnvironmentModel.acceptedFriends.first(where: { $0.id == flavor })
        }
    }

    var body: some View {
        List(shownSortedFriends, selection: $selectedFriendIds) { friend in
            HStack {
                AvatarView(avatarUrl: friend.avatarUrl, size: 32, id: friend.id)
                Text(friend.preferredName)
                Spacer()
            }
        }
        .environment(\.editMode, .constant(.active))
        .searchable(text: $searchTerm)
        .overlay {
            if showContentUnavailableView {
                ContentUnavailableView.search(text: searchTerm)
            }
        }
        .buttonStyle(.plain)
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

    private func toggleFriend(friend: Profile) {
        withAnimation {
            if taggedFriends.contains(friend) {
                taggedFriends.remove(object: friend)
            } else {
                taggedFriends.append(friend)
            }
        }
    }
}
