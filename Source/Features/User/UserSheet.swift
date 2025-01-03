import Components

import Extensions
import Logging
import Models
import Repositories
import SwiftUI

struct ProfilePickerSheet: View {
    private let logger = Logger(label: "ProfilePickerSheet")
    @Environment(Repository.self) private var repository
    @Environment(ProfileModel.self) private var profileModel
    @Environment(\.dismiss) private var dismiss
    @State private var state: ScreenState = .populated
    @State private var searchTerm: String = ""
    @State private var searchedFor: String?
    @State private var searchResults = [Profile.Saved]()

    let mode: Mode
    let onSubmit: () -> Void

    var body: some View {
        List(searchResults) { profile in
            HStack {
                AvatarView(profile: profile)
                    .avatarSize(.large)
                Text(profile.preferredName)
                Spacer()
                HStack {
                    if mode == .add {
                        HStack {
                            if !profileModel.friends
                                .contains(where: { $0.containsUser(userId: profile.id) })
                            {
                                AsyncButton("user.addFriend.label", systemImage: "person.badge.plus", action: {
                                    await profileModel.sendFriendRequest(
                                        receiver: profile.id,
                                        onSuccess: {
                                            dismiss()
                                            onSubmit()
                                        }
                                    )
                                })
                                .labelStyle(.iconOnly)
                                .imageScale(.large)
                            }
                        }
                    }
                    if mode == .block {
                        if !profileModel.blockedUsers
                            .contains(where: { $0.containsUser(userId: profile.id) })
                        {
                            AsyncButton(
                                "user.block.label",
                                systemImage: "person.fill.xmark",
                                action: { await profileModel.blockUser(user: profile, onSuccess: {
                                    onSubmit()
                                    dismiss()
                                })
                                }
                            )
                            .imageScale(.large)
                        }
                    }
                }
            }
        }
        .overlay {
            if state != .populated {
                ScreenStateOverlayView(state: state) {
                    await searchUsers(searchTerm: searchTerm)
                }
            } else if searchResults.isEmpty, let searchedFor {
                ContentUnavailableView.search(text: searchedFor)
            } else if searchResults.isEmpty {
                ContentUnavailableView("user.search.empty.title", systemImage: "magnifyingglass")
            }
        }
        .navigationTitle("user.search.navigationTitle")
        .toolbar {
            toolbarContent
        }
        .searchable(text: $searchTerm)
        .disableAutocorrection(true)
        .onSubmit(of: .search) { Task { await searchUsers(searchTerm: searchTerm) }
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    private func searchUsers(searchTerm: String) async {
        state = .loading
        do {
            let searchResults = try await repository.profile.search(searchTerm: searchTerm, currentUserId: profileModel.id)
            withAnimation {
                searchedFor = searchTerm
                self.searchResults = searchResults
                state = .populated
            }
        } catch {
            guard !error.isCancelled else { return }
            state = .error(error)
            logger.error("Failed searching users. Error: \(error) (\(#file):\(#line))")
        }
    }
}

extension ProfilePickerSheet {
    enum Mode {
        case add
        case block
    }
}
