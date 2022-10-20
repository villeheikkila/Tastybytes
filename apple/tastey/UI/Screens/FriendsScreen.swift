import AlertToast
import Foundation
import SwiftUI

struct FriendsScreenView: View {
    var profile: Profile

    @StateObject private var viewModel = ViewModel()
    
    var addFriendButton: some View {
        HStack {
            if profile.isCurrentUser() {
                Button(action: { viewModel.showUserSearchSheet.toggle() }) {
                    Image(systemName: "plus").imageScale(.large)
                }
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.friends, id: \.self) { friend in
                    if profile.isCurrentUser() {
                        FriendListItem(friend: friend,
                                       onAccept: { id in viewModel.updateFriendRequest(id: id, newStatus: .accepted) },
                                       onBlock: { id in viewModel.updateFriendRequest(id: id, newStatus: .blocked) },
                                       onDelete: { id in viewModel.removeFriendRequest(id: id) })
                    } else {
                        FriendListItemSimple(profile: friend.getFriend(userId: profile.id))
                    }
                }
            }
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.inline)
        }
        .refreshable {
            viewModel.loadFriends(userId: profile.id)
        }
        .task {
            viewModel.loadFriends(userId: profile.id)
        }
        .navigationBarItems(
            trailing: addFriendButton)
        .sheet(isPresented: $viewModel.showUserSearchSheet) {
            UserSearchView(actions: { profile in
                HStack {
                    if !viewModel.friends.contains(where: { $0.containsUser(userId: profile.id) }) {
                        Button(action: { viewModel.sendFriendRequest(receiver: profile.id) }) {
                            Image(systemName: "person.badge.plus")
                                .imageScale(.large)
                        }
                    }
                }

                .errorAlert(error: $viewModel.modalError)
            }).presentationDetents([.medium])
        }
        .errorAlert(error: $viewModel.error)
        .toast(isPresenting: $viewModel.showToast, duration: 2, tapToDismiss: true) {
            AlertToast(type: .complete(.green), title: "Friend Request Sent!")
        }
    }
}

extension FriendsScreenView {
   @MainActor class ViewModel: ObservableObject {
        @Published var searchText: String = ""
        @Published var products = [Profile]()
        @Published var friends = [Friend]()
        @Published var showToast = false
        @Published var showUserSearchSheet = false

        @Published var error: Error?
        @Published var modalError: Error?

        func sendFriendRequest(receiver: UUID) {
            let newFriend = NewFriend(receiver: receiver, status: .pending)

            Task {
                do {
                    let newFriend = try await repository.friend.insert(newFriend: newFriend)
                    DispatchQueue.main.async {
                        self.friends.append(newFriend)
                        self.showToast = true
                        self.showUserSearchSheet = false
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.modalError = error
                    }
                }
            }
        }

        func updateFriendRequest(id: Int, newStatus: FriendStatus) {
            let friend = friends.first(where: { $0.id == id })
            if let friend = friend {
                let friendUpdate = FriendUpdate(user_id_1: friend.sender.id, user_id_2: friend.receiver.id, status: newStatus)
                Task {
                    do {
                        let updatedFriend = try await repository.friend.update(id: id, friendUpdate: friendUpdate)
                        DispatchQueue.main.async {
                            self.friends.removeAll(where: { $0.id == updatedFriend.id })
                        }
                        DispatchQueue.main.async {
                            self.friends.append(updatedFriend)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.error = error
                        }
                    }
                }
            }
        }

        func removeFriendRequest(id: Int) {
            Task {
                do {
                    try await repository.friend.delete(id: id)
                    DispatchQueue.main.async {
                        self.friends.removeAll(where: { $0.id == id })
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.error = error
                    }
                }
            }
        }

        func loadFriends(userId: UUID) {
            Task {
                do {
                    let friends = try await repository.friend.getByUserId(userId: userId)
                    DispatchQueue.main.async {
                        self.friends = friends
                        print(friends)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.error = error
                    }
                }
            }
        }
    }
}

struct FriendListItemSimple: View {
    let profile: Profile

    var body: some View {
        HStack(alignment: .center) {
            AvatarView(avatarUrl: profile.getAvatarURL(), size: 32, id: profile.id)
            VStack {
                HStack {
                    Text(profile.getPreferedName())
                    Spacer()
                }
            }
        }
        .padding(.all, 10)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
        .padding([.leading, .trailing], 10)
    }
}

struct FriendListItem: View {
    let friend: Friend
    let profile: Profile
    let currentUser: UUID
    let onAccept: (_ id: Int) -> Void
    let onBlock: (_ id: Int) -> Void
    let onDelete: (_ id: Int) -> Void

    init(friend: Friend,
         onAccept: @escaping (_ id: Int) -> Void,
         onBlock: @escaping (_ id: Int) -> Void,
         onDelete: @escaping (_ id: Int) -> Void) {
        self.friend = friend
        profile = friend.getFriend(userId: repository.auth.getCurrentUserId())
        currentUser = repository.auth.getCurrentUserId()
        self.onAccept = onAccept
        self.onBlock = onBlock
        self.onDelete = onDelete
    }

    var body: some View {
        HStack(alignment: .center) {
            AvatarView(avatarUrl: profile.getAvatarURL(), size: 32, id: profile.id)
            VStack {
                HStack {
                    Text(profile.getPreferedName())
                    if friend.status == FriendStatus.pending {
                        Text("(\(friend.status.rawValue.capitalized))").font(.footnote)
                    }
                    Spacer()
                    if friend.isPending(userId: currentUser) {
                        HStack(alignment: .center) {
                            Button(action: {
                                onDelete(friend.id)
                            }) {
                                Image(systemName: "person.fill.xmark").imageScale(.large)
                            }

                            Button(action: {
                                onAccept(friend.id)
                            }) {
                                Image(systemName: "person.badge.plus").imageScale(.large)
                            }
                        }
                    }
                }
            }
        }
        .contextMenu {
            Button(action: {
                onDelete(friend.id)
            }) {
                Label("Delete", systemImage: "person.fill.xmark").imageScale(.large)
            }

            Button(action: {
                onBlock(friend.id)
            }) {
                Label("Block", systemImage: "person.2.slash").imageScale(.large)
            }
        }
        .padding(.all, 10)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
        .padding([.leading, .trailing], 10)
    }
}
