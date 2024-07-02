import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

struct UserSheet: View {
    private let logger = Logger(category: "UserSheet")
    @Environment(Repository.self) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var state: ScreenState = .populated
    @State private var searchTerm: String = ""
    @State private var searchedFor: String?
    @State private var searchResults = [Profile]()

    let onSubmit: () -> Void
    let mode: Mode

    init(
        mode: Mode,
        onSubmit: @escaping () -> Void
    ) {
        self.mode = mode
        self.onSubmit = onSubmit
    }

    var body: some View {
        List(searchResults) { profile in
            HStack {
                Avatar(profile: profile)
                    .avatarSize(.large)
                Text(profile.preferredName)
                Spacer()
                HStack {
                    if mode == .add {
                        HStack {
                            if !friendEnvironmentModel.friends
                                .contains(where: { $0.containsUser(userId: profile.id) })
                            {
                                ProgressButton("user.addFriend.label", systemImage: "person.badge.plus", action: {
                                    await friendEnvironmentModel.sendFriendRequest(
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
                        if !friendEnvironmentModel.blockedUsers
                            .contains(where: { $0.containsUser(userId: profile.id) })
                        {
                            ProgressButton(
                                "user.block.label",
                                systemImage: "person.fill.xmark",
                                action: { await friendEnvironmentModel.blockUser(user: profile, onSuccess: {
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
                ScreenStateOverlayView(state: state, errorDescription: "") {
                    await searchUsers()
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
        .onSubmit(of: .search) { Task { await searchUsers() }
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarDismissAction()
    }

    func searchUsers() async {
        state = .loading
        switch await repository.profile.search(searchTerm: searchTerm, currentUserId: profileEnvironmentModel.id) {
        case let .success(searchResults):
            withAnimation {
                searchedFor = searchTerm
                self.searchResults = searchResults
                state = .populated
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            state = .error([error])
            logger.error("Failed searching users. Error: \(error) (\(#file):\(#line))")
        }
    }
}

extension UserSheet {
    enum Mode {
        case add
        case block
    }
}
