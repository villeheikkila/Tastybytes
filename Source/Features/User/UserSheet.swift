import Components
import EnvironmentModels
import Extensions
import Models
import OSLog
import Repositories
import SwiftUI

private let logger = Logger(category: "UserSheet")

@MainActor
struct UserSheet: View {
    @Environment(\.repository) private var repository
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchTerm: String = ""
    @State private var alertError: AlertError?
    @State private var searchedFor: String?
    @State private var isLoading = false
    @State private var searchResults = [Profile]()

    let onSubmit: @MainActor () -> Void
    let mode: Mode

    init(
        mode: Mode,
        onSubmit: @escaping () -> Void
    ) {
        self.mode = mode
        self.onSubmit = onSubmit
    }

    private var showContentUnavailableView: Bool {
        !searchTerm.isEmpty && !isLoading && searchResults.isEmpty
    }

    var body: some View {
        List(searchResults) { profile in
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
        .overlay {
            if showContentUnavailableView, let searchedFor {
                ContentUnavailableView.search(text: searchedFor)
            } else if isLoading {
                ProgressView()
            }
        }
        .navigationTitle("Search users")
        .toolbar {
            toolbarContent
        }
        .searchable(text: $searchTerm)
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
        isLoading = true
        switch await repository.profile.search(searchTerm: searchTerm, currentUserId: currentUserId) {
        case let .success(searchResults):
            withAnimation {
                self.searchedFor = searchTerm
                self.isLoading = false
                self.searchResults = searchResults
            }
        case let .failure(error):
            guard !error.isCancelled else { return }
            alertError = .init()
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
