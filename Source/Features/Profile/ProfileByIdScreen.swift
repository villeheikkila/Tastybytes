
import Models
import Repositories
import SwiftUI

struct ProfileByIdScreen: View {
    @Environment(Repository.self) private var repository
    @Environment(ProfileModel.self) private var profileModel
    @State private var state: ScreenState = .loading
    @State private var profile: Profile.Saved?

    let id: Profile.Id

    var body: some View {
        if let profile {
            content(profile: profile)
        } else {
            loading
        }
    }

    @ViewBuilder private func content(profile: Profile.Saved) -> some View {
        ProfileInnerScreen(
            profile: profile,
            isCurrentUser: profileModel.id == profile.id
        )
    }

    @ViewBuilder private var loading: some View {
        List {}
            .overlay {
                ScreenStateOverlayView(state: state) {
                    await initialize()
                }
            }
            .initialTask {
                if state == .loading {
                    await initialize()
                }
            }
    }

    func initialize() async {
        do {
            profile = try await repository.profile.getById(id: id)
            state = .populated
        } catch {
            state = .error(error)
        }
    }
}
