import Foundation
import SwiftUI

struct FriendsScreenView: View {
    var profile: Profile
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var toastManager: ToastManager
    @EnvironmentObject var noficationManager: NotificationManager
    @State var friendToBeRemoved: Friend?
    @State var showRemoveFriendConfirmation = false

    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.friends, id: \.self) { friend in
                    if profile == profileManager.getProfile() {
                        FriendListItemView(friend: friend,
                                           currentUser: profileManager.getProfile(),
                                           onAccept: { id in viewModel.updateFriendRequest(id: id, newStatus: .accepted) },
                                           onBlock: { id in viewModel.updateFriendRequest(id: id, newStatus: .blocked) },
                                           onDelete: { friend in
                                               friendToBeRemoved = friend
                                               showRemoveFriendConfirmation = true
                                           })
                    } else {
                        FriendListItemSimpleView(profile: friend.getFriend(userId: profile.id))
                    }
                }
            }
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.inline)
        }
        .refreshable {
            viewModel.loadFriends(userId: profile.id, currentUser: profileManager.getProfile())
        }
        .task {
            viewModel.loadFriends(userId: profile.id, currentUser: profileManager.getProfile())
        }
        .task {
            if profile == profileManager.getProfile() {
                noficationManager.markAllFriendRequestsAsRead()
            }
        }
        .navigationBarItems(
            trailing: addFriendButton)
        .sheet(isPresented: $viewModel.showUserSearchSheet) {
            UserSheetView(actions: { profile in
                HStack {
                    if !viewModel.friends.contains(where: { $0.containsUser(userId: profile.id) }) {
                        Button(action: { viewModel.sendFriendRequest(receiver: profile.id, onSuccess: {
                            toastManager.toggle(.success("Friend Request Sent!"))
                        }) }) {
                            Image(systemName: "person.badge.plus")
                                .imageScale(.large)
                        }
                    }
                }
                .errorAlert(error: $viewModel.modalError)
            })
            .presentationDetents([.medium])
        }
        .errorAlert(error: $viewModel.error)
        .confirmationDialog("delete_friend",
                            isPresented: $showRemoveFriendConfirmation
        ) {
            Button("Remove \(friendToBeRemoved?.getFriend(userId: profileManager.getId()).preferredName ?? "??")", role: .destructive, action: {
                if let friend = friendToBeRemoved {
                    viewModel.removeFriendRequest(friend)
                }
            })
        }
    }

    var addFriendButton: some View {
        HStack {
            if profile == profileManager.getProfile() {
                Button(action: { viewModel.showUserSearchSheet.toggle() }) {
                    Image(systemName: "plus").imageScale(.large)
                }
            }
        }
    }
}

extension FriendsScreenView {
    @MainActor class ViewModel: ObservableObject {
        @Published var searchText: String = ""
        @Published var products = [Profile]()
        @Published var friends = [Friend]()
        @Published var showUserSearchSheet = false

        @Published var error: Error?
        @Published var modalError: Error?

        func sendFriendRequest(receiver: UUID, onSuccess: @escaping () -> Void) {
            Task {
                switch await repository.friend.insert(newFriend: Friend.NewRequest(receiver: receiver, status: .pending)) {
                case let .success(newFriend):
                    await MainActor.run {
                        self.friends.append(newFriend)
                        self.showUserSearchSheet = false
                        onSuccess()
                    }
                case let .failure(error):
                    await MainActor.run {
                        print(error)
                        self.modalError = error
                    }
                }
            }
        }

        func updateFriendRequest(id: Int, newStatus: Friend.Status) {
            if let friend = friends.first(where: { $0.id == id }) {
                let friendUpdate = Friend.UpdateRequest(user_id_1: friend.sender.id, user_id_2: friend.receiver.id, status: newStatus)
                Task {
                    switch await repository.friend.update(id: id, friendUpdate: friendUpdate) {
                    case let .success(updatedFriend):
                        await MainActor.run {
                            self.friends.removeAll(where: { $0.id == updatedFriend.id })
                        }
                        if updatedFriend.status != Friend.Status.blocked {
                            await MainActor.run {
                                self.friends.append(updatedFriend)
                            }
                        }
                    case let .failure(error):
                        await MainActor.run {
                            self.error = error
                        }
                    }
                }
            }
        }

        func removeFriendRequest(_ friend: Friend) {
            Task {
                switch await repository.friend.delete(id: friend.id) {
                case .success():
                    await MainActor.run {
                        self.friends.remove(object: friend)
                    }
                case let .failure(error):
                    await MainActor.run {
                        self.error = error
                    }
                }
            }
        }

        func loadFriends(userId: UUID, currentUser: Profile) {
            Task {
                switch await repository.friend.getByUserId(userId: userId, status: currentUser.id == userId ? .none : Friend.Status.accepted) {
                case let .success(friends):
                    await MainActor.run {
                        self.friends = friends
                    }
                case let .failure(error):
                    await MainActor.run {
                        self.error = error
                    }
                }
            }
        }
    }
}

struct FriendListItemSimpleView: View {
    let profile: Profile

    var body: some View {
        NavigationLink(value: profile) {
            HStack(alignment: .center) {
                AvatarView(avatarUrl: profile.getAvatarURL(), size: 32, id: profile.id)
                Text(profile.preferredName)
                    .foregroundColor(.primary)
                Spacer()
            }
        }
        .padding(.all, 10)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
        .padding([.leading, .trailing], 10)
    }
}

struct FriendListItemView: View {
    let friend: Friend
    let profile: Profile
    let currentUser: Profile
    let onAccept: (_ id: Int) -> Void
    let onBlock: (_ id: Int) -> Void
    let onDelete: (_ friend: Friend) -> Void

    init(friend: Friend,
         currentUser: Profile,
         onAccept: @escaping (_ id: Int) -> Void,
         onBlock: @escaping (_ id: Int) -> Void,
         onDelete: @escaping (_ friend: Friend) -> Void) {
        self.friend = friend
        profile = friend.getFriend(userId: currentUser.id)
        self.currentUser = currentUser
        self.onAccept = onAccept
        self.onBlock = onBlock
        self.onDelete = onDelete
    }

    var body: some View {
        NavigationLink(value: friend.getFriend(userId: currentUser.id)) {
            HStack(alignment: .center) {
                AvatarView(avatarUrl: profile.getAvatarURL(), size: 32, id: profile.id)
                VStack {
                    HStack {
                        Text(profile.preferredName)
                            .foregroundColor(.primary)
                        if friend.status == Friend.Status.pending {
                            Text("(\(friend.status.rawValue.capitalized))")
                                .font(.footnote)
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        if friend.isPending(userId: currentUser.id) {
                            HStack(alignment: .center) {
                                Button(action: {
                                    onDelete(friend)
                                }) {
                                    Image(systemName: "person.fill.xmark")
                                        .imageScale(.large)
                                }

                                Button(action: {
                                    onAccept(friend.id)
                                }) {
                                    Image(systemName: "person.badge.plus")
                                        .imageScale(.large)
                                }
                            }
                        }
                    }
                }
            }
        }
        .contextMenu {
            Button(action: {
                onDelete(friend)
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
