import Components
import EnvironmentModels
import Models
import Repositories
import SwiftUI

struct ProfileScreen: View {
    @Environment(Router.self) private var router
    @Environment(Repository.self) private var repository
    @Environment(FriendEnvironmentModel.self) private var friendEnvironmentModel
    @Environment(ProfileEnvironmentModel.self) private var profileEnvironmentModel
    @State private var state: ScreenState

    private let id: Profile.Id
    @State private var profile: Profile.Saved?

    init(profile: Profile.Saved) {
        _profile = State(initialValue: profile)
        _state = State(initialValue: .populated)
        id = profile.id
    }

    init(id: Profile.Id) {
        self.id = id
        _state = State(initialValue: .loading)
    }

    var body: some View {
        ZStack {
            if let profile {
                ProfileView(
                    profile: profile,
                    isCurrentUser: profileEnvironmentModel.id == profile.id
                )
            }
        }
        .navigationTitle(profile?.preferredName ?? "")
        .toolbar {
            toolbarContent
        }
        .initialTask {
            if state == .loading {
                await initialize()
            }
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        if let profile {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    ProfileShareLinkView(profile: profile)
                    if friendEnvironmentModel.hasNoFriendStatus(friend: profile) {
                        AsyncButton(
                            "friend.friendRequest.send.label",
                            action: { await friendEnvironmentModel.sendFriendRequest(receiver: profile.id) }
                        )
                    } else if let friend = friendEnvironmentModel.isPendingCurrentUserApproval(profile) {
                        AsyncButton(
                            "friend.friendRequest.accept.label",

                            action: {
                                await friendEnvironmentModel.updateFriendRequest(friend: friend, newStatus: .accepted)
                            }
                        )
                    }
                    Divider()
                    ReportButton(entity: .profile(profile))
                    Divider()
                    AdminRouterLink(open: .sheet(.profileAdmin(id: profile.id, onDelete: { _ in
                        router.removeLast()
                    })))
                } label: {
                    Label("labels.menu", systemImage: "ellipsis")
                        .labelStyle(.iconOnly)
                }
            }
        }
    }

    func initialize() async {
        do {
            profile = try await repository.profile.getById(id: id)
            state = .populated
        } catch {
            state = .error([error])
        }
    }
}
