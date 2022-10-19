import AlertToast
import Foundation
import SwiftUI

struct FriendsScreenView: View {
    @StateObject private var model = FriendsViewModel()
    @State private var searchText = ""

    var body: some View {
        VStack {
            VStack {
                    ForEach(model.friends, id: \.self) { friend in
                        FriendListItem(friend: friend,
                                       onAccept: { id in model.updateFriendRequest(id: id, newStatus: .accepted) },
                                       onBlock: { id in model.updateFriendRequest(id: id, newStatus: .blocked) },
                                       onDelete: { id in model.removeFriendRequest(id: id) })
                    }
            }
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                model.loadFriends(userId: SupabaseAuthRepository().getCurrentUserId())
            }

            Spacer()

            Button(action: {
                model.showUserSearchSheet.toggle()
            }) {
                Text("Find users")
            }
            .sheet(isPresented: $model.showUserSearchSheet) {
                UserSearchView(actions: { profile in
                    HStack {
                        if !model.friends.contains(where: { $0.containsUser(userId: profile.id) }) {
                            Button(action: { model.sendFriendRequest(receiver: profile.id) }) {
                                Image(systemName: "person.badge.plus")
                                    .imageScale(.large)
                            }
                        }
                    }

                    .errorAlert(error: $model.modalError)
                }).presentationDetents([.medium])
            }

        }
        .errorAlert(error: $model.error)
        .toast(isPresenting: $model.showToast, duration: 2, tapToDismiss: true) {
            AlertToast(type: .complete(.green), title: "Friend Request Sent!")
        }
    }
}

extension FriendsScreenView {
    class FriendsViewModel: ObservableObject {
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
                    let newFriend = try await SupabaseFriendsRepository().insert(newFriend: newFriend)
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
                        let updatedFriend = try await SupabaseFriendsRepository().updateStatus(id: id, friendUpdate: friendUpdate)
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
                    try await SupabaseFriendsRepository().delete(id: id)
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
                    let friends = try await SupabaseFriendsRepository().loadByUserId(userId: userId)
                    DispatchQueue.main.async {
                        self.friends = friends
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
        profile = friend.getFriend(userId: SupabaseAuthRepository().getCurrentUserId())
        currentUser = SupabaseAuthRepository().getCurrentUserId()
        self.onAccept = onAccept
        self.onBlock = onBlock
        self.onDelete = onDelete
    }

    var body: some View {
        HStack {
            CollapsibleView(
                content: {
                    HStack(alignment: .center) {
                        AvatarView(avatarUrl: profile.getAvatarURL(), size: 32, id: profile.id)
                        VStack {
                            HStack {
                                Text(profile.username)
                                Spacer()
                            }
                            if friend.status == FriendStatus.pending {
                                HStack {
                                    Text(friend.status.rawValue.capitalized).font(.footnote)
                                    Spacer()
                                }
                            }
                        }
                    }
                },
                expandedContent: {
                    HStack {
                        if friend.isPending(userId: currentUser) {
                            Button(action: {
                                onAccept(friend.id)
                            }) {
                                Label("Accept", systemImage: "person.badge.plus").imageScale(.large)
                            }
                            Spacer()
                        }
                        Button(action: {
                            onDelete(friend.id)
                        }) {
                            Label("Delete", systemImage: "person.badge.minus").imageScale(.large)
                        }
                        Spacer()
                        
                        if friend.isPending(userId: currentUser) {
                            Button(action: {
                                onBlock(friend.id)
                            }) {
                                Label("Block", systemImage: "person.2.slash").imageScale(.large)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                }
            )
            .frame(maxWidth: .infinity)
        }
        .padding(.all, 10)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
            .padding([.leading, .trailing], 10)
    }
}
