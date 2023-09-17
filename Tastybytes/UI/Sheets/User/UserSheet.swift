import EnvironmentModels
import Models
import OSLog
import Repositories
import SwiftUI

private let logger = Logger(category: "UserSheet")

struct UserSheet: View {
    @Environment(\.repository) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(FeedbackEnvironmentModel.self) private var feedbackEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
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
        List {
            ForEach(searchResults) { profile in
                HStack {
                    AvatarView(avatarUrl: profile.avatarUrl, size: 32, id: profile.id)
                    Text(profile.preferredName)
                    Spacer()
                    HStack {
                        if mode == .add {
                            HStack {
                                if !friendEnvironmentModel.friends
                                    .contains(where: { $0.containsUser(userId: profile.id) })
                                {
                                    ProgressButton("Add as a friend", systemImage: "person.badge.plus", action: {
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
                                    "Block",
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
        }
        .navigationTitle("Search users")
        .toolbar {
            toolbarContent
        }
        .searchable(text: $searchText)
        .disableAutocorrection(true)
        .onSubmit(of: .search) { Task { await searchUsers(currentUserId: profileEnvironmentModel.id) }
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button("Close", role: .cancel, action: { dismiss() })
                .bold()
        }
    }

    func searchUsers(currentUserId: UUID) async {
        switch await repository.profile.search(searchTerm: searchText, currentUserId: currentUserId) {
        case let .success(searchResults):
            await MainActor.run {
                withAnimation {
                    self.searchResults = searchResults
                }
            }
        case let .failure(error):
            guard !error.localizedDescription.contains("cancelled") else { return }
            feedbackEnvironmentModel.toggle(.error(.unexpected))
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
